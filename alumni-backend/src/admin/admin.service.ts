import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { FiltrosEgresadosDto } from './dto/filtros-egresados.dto';
import { SearchEgresadosDto } from './dto/search-egresados.dto';
import { CreatePreguntaDto, UpdatePreguntaDto } from './dto/pregunta.dto';
import { CreateModuloDto, UpdateModuloDto } from './dto/modulo.dto';
import { DashboardStats } from './interfaces/dashboard-stats.interface';
import { NotificacionesService } from '../notificaciones/notificaciones.service';
import { MailService } from '../mail/mail.service';
import * as XLSX from 'xlsx';
import * as ExcelJS from 'exceljs';

@Injectable()
export class AdminService {
  private readonly logger = new Logger(AdminService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificacionesService: NotificacionesService,
    private readonly mailService: MailService,
  ) { }

  /**
   * Get paginated list of egresados with filters
   */
  async getListaEgresados(filtros: FiltrosEgresadosDto) {
    const { page = 1, limit = 20, search, ...filters } = filtros;
    const offset = (page - 1) * limit;

    // Build query
    let query = this.supabaseService
      .getClient()
      .from('egresados')
      .select(
        `
        id,
        nombre,
        apellido,
        correo_institucional,
        id_universitario,
        celular,
        estado_laboral_id,
        habilitado,
        proceso_grado_completo,
        autoevaluacion_habilitada,
        autoevaluacion_completada,
        created_at,
        carrera_id,
        carreras (
          nombre
        ),
        estados_laborales (
          nombre
        )
      `,
        { count: 'exact' },
      )
      .is('deleted_at', null);

    // Apply filters
    if (filters.carrera_id) {
      query = query.eq('carrera_id', filters.carrera_id);
    }
    if (filters.habilitado !== undefined) {
      query = query.eq('habilitado', filters.habilitado);
    }
    if (filters.proceso_grado_completo !== undefined) {
      query = query.eq('proceso_grado_completo', filters.proceso_grado_completo);
    }
    if (filters.autoevaluacion_completada !== undefined) {
      query = query.eq('autoevaluacion_completada', filters.autoevaluacion_completada);
    }

    // Search (properly wrapped in parentheses)
    if (search) {
      const s = search.replace(/%/g, '\\%'); // escape percent if needed
      query = query.or(
        `(nombre.ilike.%${s}%,apellido.ilike.%${s}%,correo_institucional.ilike.%${s}%,id_universitario.ilike.%${s}%)`,
      );
    }

    // Pagination
    query = query.range(offset, offset + limit - 1).order('created_at', { ascending: false });

    const { data, error, count } = await query;

    if (error) {
      this.logger.error(`Error fetching egresados: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener lista de egresados');
    }

    return {
      data: data || [],
      total: count || 0,
      page,
      limit,
      totalPages: Math.ceil((count || 0) / limit),
    };
  }

  /**
   * Get detailed information of a specific egresado
   */
  async getDetalleEgresado(egresadoId: string) {
    const { data: egresado, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select(
        `
        *,
        carreras (
          nombre,
          codigo
        )
      `,
      )
      .eq('id', egresadoId)
      .is('deleted_at', null)
      .single();

    if (error || !egresado) {
      throw new NotFoundException('Egresado no encontrado');
    }

    // Get documents count
    const { count: documentosCount } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('*', { count: 'exact', head: true })
      .eq('egresado_id', egresadoId)
      .eq('es_unificado', false)
      .is('deleted_at', null);

    // Get autoevaluacion progress
    const { count: totalPreguntas } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*', { count: 'exact', head: true })
      .eq('activa', true);

    const { count: respuestasCount } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select('*', { count: 'exact', head: true })
      .eq('egresado_id', egresadoId);

    const progresoAutoevaluacion =
      (totalPreguntas || 0) > 0
        ? Math.round(((respuestasCount || 0) / (totalPreguntas || 1)) * 100)
        : 0;

    return {
      perfil: egresado,
      estadisticas: {
        documentos_subidos: documentosCount || 0,
        progreso_autoevaluacion: progresoAutoevaluacion,
      },
    };
  }

  /**
   * Get documents of a specific egresado
   */
  async getDocumentosEgresado(egresadoId: string) {
    // Verify egresado exists
    const { data: egresado } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id')
      .eq('id', egresadoId)
      .maybeSingle();

    if (!egresado) {
      throw new NotFoundException('Egresado no encontrado');
    }

    // Get all documents
    const { data: documentos, error } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('*')
      .eq('egresado_id', egresadoId)
      .is('deleted_at', null)
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Error fetching documents: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener documentos');
    }

    // Generate signed URLs (handle errors per file)
    const documentosConUrls = await Promise.all(
      (documentos || []).map(async (doc) => {
        try {
          const { data, error: urlError } = await this.supabaseService
            .getClient()
            .storage.from('egresados-documentos')
            .createSignedUrl(doc.ruta_storage, 3600);

          if (urlError) {
            this.logger.warn(`Failed to create signed URL for ${doc.id}: ${urlError.message}`);
            return {
              ...doc,
              url_descarga: '',
              url_error: urlError.message,
            };
          }

          return {
            ...doc,
            url_descarga: data?.signedUrl || '',
          };
        } catch (err) {
          this.logger.warn(`Unexpected error creating signed URL for ${doc.id}: ${err.message}`);
          return {
            ...doc,
            url_descarga: '',
            url_error: err.message,
          };
        }
      }),
    );

    return documentosConUrls;
  }

  /**
   * Get autoevaluacion responses of a specific egresado
   */
  async getRespuestasAutoevaluacion(egresadoId: string) {
    // Verify egresado exists
    const { data: egresado } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id, nombre, apellido')
      .eq('id', egresadoId)
      .maybeSingle();

    if (!egresado) {
      throw new NotFoundException('Egresado no encontrado');
    }

    // Get responses with questions
    const { data: respuestas, error } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select(
        `
        *,
        preguntas_autoevaluacion (
          texto,
          tipo,
          categoria
        )
      `,
      )
      .eq('egresado_id', egresadoId)
      .order('created_at', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching responses: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener respuestas');
    }

    return {
      egresado: {
        nombre: `${egresado.nombre} ${egresado.apellido}`,
      },
      respuestas: respuestas || [],
    };
  }

  /**
   * Get dashboard statistics
   */
  async getDashboardStats(): Promise<DashboardStats> {
    const client = this.supabaseService.getClient();

    // Total egresados
    const { count: totalEgresados } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .is('deleted_at', null);

    // Egresados habilitados
    const { count: egresadosHabilitados } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('habilitado', true)
      .is('deleted_at', null);

    // Documentos completos
    const { count: documentosCompletos } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('proceso_grado_completo', true)
      .is('deleted_at', null);

    // Autoevaluaciones completas
    const { count: autoevaluacionesCompletas } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('autoevaluacion_completada', true)
      .is('deleted_at', null);

    // Stats por carrera (optimizado: traigo todos los egresados una sola vez y agrego en memoria)
    const { data: carreras } = await client
      .from('carreras')
      .select('id, nombre')
      .eq('activa', true);

    const { data: egresadosAll } = await client
      .from('egresados')
      .select('carrera_id, habilitado, proceso_grado_completo, autoevaluacion_completada, estado_laboral_id, estados_laborales(nombre)')
      .is('deleted_at', null);

    const resumenPorCarreraMap = new Map<
      string,
      {
        total: number;
        habilitados: number;
        documentos_completos: number;
        autoevaluaciones_completas: number;
        empleados: number;
        desempleados: number;
      }
    >();

    (egresadosAll || []).forEach((e) => {
      const cid = e.carrera_id || 'unknown';
      const curr = resumenPorCarreraMap.get(cid) || {
        total: 0,
        habilitados: 0,
        documentos_completos: 0,
        autoevaluaciones_completas: 0,
        empleados: 0,
        desempleados: 0,
      };
      curr.total++;
      if (e.habilitado) curr.habilitados++;
      if (e.proceso_grado_completo) curr.documentos_completos++;
      if (e.autoevaluacion_completada) curr.autoevaluaciones_completas++;

      // Employment stats
      const estado = (e.estados_laborales as any)?.nombre?.toLowerCase() || '';
      if (estado === 'empleado' || estado === 'independiente' || estado === 'trabajando') {
        curr.empleados++;
      } else if (estado === 'desempleado') {
        curr.desempleados++;
      }

      resumenPorCarreraMap.set(cid, curr);
    });

    const porCarrera = (carreras || []).map((c) => {
      const stat = resumenPorCarreraMap.get(c.id) || {
        total: 0,
        habilitados: 0,
        documentos_completos: 0,
        autoevaluaciones_completas: 0,
        empleados: 0,
        desempleados: 0,
      };
      return {
        carrera: c.nombre,
        total: stat.total || 0,
        habilitados: stat.habilitados || 0,
        documentos_completos: stat.documentos_completos || 0,
        autoevaluaciones_completas: stat.autoevaluaciones_completas || 0,
        empleados: stat.empleados || 0,
        desempleados: stat.desempleados || 0,
      };
    });

    return {
      total_egresados: totalEgresados || 0,
      egresados_habilitados: egresadosHabilitados || 0,
      documentos_completos: documentosCompletos || 0,
      autoevaluaciones_completas: autoevaluacionesCompletas || 0,
      por_carrera: porCarrera,
    };
  }

  /**
   * Get distribution of egresados by career
   */
  async getDistribucionPorCarrera() {
    const client = this.supabaseService.getClient();

    const { data: egresados } = await client
      .from('egresados')
      .select('carrera_id, carreras(nombre)')
      .is('deleted_at', null);

    // Group by career
    const grouped = (egresados || []).reduce((acc: any, e: any) => {
      const carrera = e.carreras?.nombre || 'Sin carrera';
      acc[carrera] = (acc[carrera] || 0) + 1;
      return acc;
    }, {});

    return Object.entries(grouped).map(([carrera, total]) => ({
      carrera,
      total,
    }));
  }

  /**
   * Get employment rate (empleados vs desempleados)
   */
  async getTasaEmpleabilidad() {
    const client = this.supabaseService.getClient();

    const { data: egresados, error } = await client
      .from('egresados')
      .select('estado_laboral_id, estados_laborales(nombre)')
      .is('deleted_at', null)
      .not('estado_laboral_id', 'is', null);

    if (error) {
      this.logger.error(`Error getting employment rate: ${error.message}`);
      throw new Error(`Error getting employment rate: ${error.message}`);
    }

    this.logger.log(`Found ${egresados?.length || 0} egresados with estado_laboral`);

    const stats = (egresados || []).reduce(
      (acc: any, e: any) => {
        const estado = (e.estados_laborales as any)?.nombre?.toLowerCase() || '';
        if (estado === 'empleado' || estado === 'independiente' || estado === 'trabajando') {
          acc.empleados++;
        } else if (estado === 'desempleado') {
          acc.desempleados++;
        } else if (estado === 'estudiando') {
          acc.estudiando++;
        } else {
          acc.otros++;
        }
        return acc;
      },
      { empleados: 0, desempleados: 0, estudiando: 0, otros: 0 },
    );

    const total = stats.empleados + stats.desempleados + stats.estudiando + stats.otros;

    this.logger.log(`Employment stats: ${JSON.stringify(stats)}`);

    return {
      empleados: stats.empleados,
      desempleados: stats.desempleados,
      estudiando: stats.estudiando,
      otros: stats.otros,
      total,
      porcentaje_empleados: total > 0 ? Math.round((stats.empleados / total) * 100) : 0,
      porcentaje_desempleados: total > 0 ? Math.round((stats.desempleados / total) * 100) : 0,
    };
  }

  /**
   * Get employment rate by career
   */
  async getEmpleabilidadPorCarrera() {
    const client = this.supabaseService.getClient();

    const { data: egresados } = await client
      .from('egresados')
      .select('carrera_id, estado_laboral_id, carreras(nombre), estados_laborales(nombre)')
      .is('deleted_at', null);

    // Group by career
    const grouped = (egresados || []).reduce((acc: any, e: any) => {
      const carrera = e.carreras?.nombre || 'Sin carrera';
      if (!acc[carrera]) {
        acc[carrera] = { empleados: 0, desempleados: 0, estudiando: 0, otros: 0, total: 0 };
      }

      const estado = (e.estados_laborales as any)?.nombre?.toLowerCase() || '';
      if (estado === 'empleado' || estado === 'independiente' || estado === 'trabajando') {
        acc[carrera].empleados++;
      } else if (estado === 'desempleado') {
        acc[carrera].desempleados++;
      } else if (estado === 'estudiando') {
        acc[carrera].estudiando++;
      } else {
        acc[carrera].otros++;
      }
      acc[carrera].total++;
      return acc;
    }, {});

    return Object.entries(grouped).map(([carrera, stats]: [string, any]) => ({
      carrera,
      empleados: stats.empleados,
      desempleados: stats.desempleados,
      estudiando: stats.estudiando,
      otros: stats.otros,
      total: stats.total,
      porcentaje_empleados: stats.total > 0 ? Math.round((stats.empleados / stats.total) * 100) : 0,
    }));
  }

  /**
   * Get process funnel (stages of graduation process)
   */
  async getEmbudoProceso() {
    const client = this.supabaseService.getClient();

    const { count: totalEgresados } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .is('deleted_at', null);

    const { count: habilitados } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('habilitado', true)
      .is('deleted_at', null);

    const { count: documentosCompletos } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('proceso_grado_completo', true)
      .is('deleted_at', null);

    const { count: autoevaluacionesCompletas } = await client
      .from('egresados')
      .select('*', { count: 'exact', head: true })
      .eq('autoevaluacion_completada', true)
      .is('deleted_at', null);

    return [
      { etapa: 'Total Egresados', total: totalEgresados || 0 },
      { etapa: 'Habilitados', total: habilitados || 0 },
      { etapa: 'Documentos Completos', total: documentosCompletos || 0 },
      { etapa: 'Autoevaluación Completa', total: autoevaluacionesCompletas || 0 },
    ];
  }

  /**
   * Get competencies radar (average scores by category)
   */
  async getRadarCompetencias() {
    const client = this.supabaseService.getClient();

    const { data: respuestas } = await client
      .from('respuestas_autoevaluacion')
      .select('respuesta_numerica, preguntas_autoevaluacion(categoria, tipo)')
      .eq('preguntas_autoevaluacion.tipo', 'likert')
      .not('respuesta_numerica', 'is', null);

    if (!respuestas || respuestas.length === 0) {
      return [];
    }

    // Group by category and calculate average
    const grouped = respuestas.reduce((acc: any, r: any) => {
      const categoria = r.preguntas_autoevaluacion?.categoria || 'Sin categoría';
      if (!acc[categoria]) {
        acc[categoria] = { sum: 0, count: 0 };
      }
      acc[categoria].sum += r.respuesta_numerica;
      acc[categoria].count++;
      return acc;
    }, {});

    return Object.entries(grouped).map(([categoria, stats]: [string, any]) => ({
      categoria,
      promedio: stats.count > 0 ? Number((stats.sum / stats.count).toFixed(2)) : 0,
      total_respuestas: stats.count,
    }));
  }

  /**
   * Enable/disable a single egresado
   */
  async habilitarEgresado(egresadoId: string, habilitado: boolean) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .update({
        habilitado,
        fecha_habilitacion: habilitado ? new Date().toISOString() : null,
      })
      .eq('id', egresadoId)
      .select()
      .single();

    if (error) {
      this.logger.error(`Error updating egresado: ${error.message}`);
      throw new InternalServerErrorException('Error al actualizar egresado');
    }

    this.logger.log(`Egresado ${egresadoId} ${habilitado ? 'habilitado' : 'deshabilitado'}`);

    // Create notification if enabled
    if (habilitado) {
      await this.notificacionesService.crear({
        egresado_id: egresadoId,
        titulo: '¡Tu cuenta ha sido habilitada!',
        mensaje: 'Ya puedes subir tus documentos de grado y comenzar tu proceso.',
        tipo: 'habilitacion',
        url_accion: '/documentos',
      });

      // Send email notification (best-effort)
      try {
        await this.mailService.sendCuentaHabilitada(data.correo_institucional, data.nombre, data.apellido);
        this.logger.log(`Email sent to ${data.correo_institucional}`);
      } catch (err) {
        this.logger.error(`Failed to send email: ${err.message}`);
        // Don't throw - email is not critical
      }
    }

    return data;
  }

  /**
   * Process Excel file to enable multiple egresados
   */
  async habilitarDesdeExcel(file: Express.Multer.File, adminId: string) {
    if (!file) {
      throw new BadRequestException('No se proporcionó ningún archivo');
    }

    try {
      // Read Excel file
      const workbook = XLSX.read(file.buffer, { type: 'buffer' });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      const rawData: any[] = XLSX.utils.sheet_to_json(sheet);

      if (rawData.length === 0) {
        throw new BadRequestException('El archivo Excel está vacío');
      }

      // Normalize headers (lowercase, trim)
      const data = rawData.map((r) => {
        return Object.fromEntries(Object.entries(r).map(([k, v]) => [k.toLowerCase().trim(), v]));
      });

      const resultados = {
        procesados: data.length,
        exitosos: 0,
        errores: [] as any[],
      };

      // Get carreras for validation
      const { data: carreras } = await this.supabaseService
        .getClient()
        .from('carreras')
        .select('id, nombre');

      const carrerasMap = new Map(
        (carreras || []).map((c) => [String(c.nombre).toLowerCase(), c.id]),
      );

      // Process each row
      for (let i = 0; i < data.length; i++) {
        const row = data[i];
        const rowNumber = i + 2; // Excel rows start at 1, header is row 1

        try {
          // Accept different header names: correo_institucional, email
          const correo_institucional = row['correo_institucional'] || row['email'] || row['e-mail'];
          const nombre = row['nombre'] || row['first_name'];
          const apellido = row['apellido'] || row['last_name'];

          // Validate required fields
          if (!correo_institucional || !nombre || !apellido) {
            resultados.errores.push({
              fila: rowNumber,
              correo_institucional: correo_institucional || 'N/A',
              error: 'Faltan campos requeridos (correo_institucional, nombre, apellido)',
            });
            continue;
          }

          // Get carrera_id
          let carreraId = null;
          if (row['carrera']) {
            carreraId = carrerasMap.get(String(row['carrera']).toLowerCase());
            if (!carreraId) {
              resultados.errores.push({
                fila: rowNumber,
                correo_institucional,
                error: `Carrera "${row['carrera']}" no encontrada`,
              });
              continue;
            }
          }

          // Check if egresado exists (use maybeSingle to avoid error)
          const { data: existente, error: existeError } = await this.supabaseService
            .getClient()
            .from('egresados')
            .select('id, uid, correo_institucional, nombre, apellido')
            .eq('correo_institucional', correo_institucional)
            .maybeSingle();

          if (existeError) {
            resultados.errores.push({
              fila: rowNumber,
              correo_institucional,
              error: existeError.message,
            });
            continue;
          }

          if (existente) {
            // Update existing
            const { error: updError } = await this.supabaseService
              .getClient()
              .from('egresados')
              .update({
                habilitado: true,
                fecha_habilitacion: new Date().toISOString(),
              })
              .eq('id', existente.id);

            if (updError) {
              resultados.errores.push({
                fila: rowNumber,
                correo_institucional,
                error: updError.message,
              });
              continue;
            }

            // Create notification
            await this.notificacionesService.crear({
              egresado_id: existente.id,
              titulo: '¡Tu cuenta ha sido habilitada!',
              mensaje: 'Ya puedes subir tus documentos de grado.',
              tipo: 'habilitacion',
              url_accion: '/documentos',
            });

            resultados.exitosos++;
          } else {
            resultados.errores.push({
              fila: rowNumber,
              correo_institucional,
              error: 'Egresado no existe en el sistema. Debe registrarse primero.',
            });
          }
        } catch (err) {
          resultados.errores.push({
            fila: rowNumber,
            correo_institucional: row['correo_institucional'] || 'N/A',
            error: err.message,
          });
        }
      }

      this.logger.log(
        `Excel processed: ${resultados.exitosos} exitosos, ${resultados.errores.length} errores`,
      );

      // Log to cargas_excel table (best effort)
      try {
        await this.supabaseService.getClient().from('cargas_excel').insert({
          admin_id: adminId,
          nombre_archivo: file.originalname,
          total_registros: data.length,
          registros_procesados: resultados.procesados,
          registros_habilitados: resultados.exitosos,
          registros_errores: resultados.errores.length,
          errores_detalle: resultados.errores,
        });
      } catch (logError) {
        this.logger.warn(`Failed to log Excel upload: ${logError.message}`);
        // Continue anyway, don't fail the upload
      }

      return resultados;
    } catch (error) {
      this.logger.error(`Error processing Excel: ${error.message}`);
      throw new BadRequestException(`Error al procesar archivo Excel: ${error.message}`);
    }
  }

  /**
   * Advanced search for egresados
   */
  async searchEgresados(query: SearchEgresadosDto) {
    const {
      q,
      carrera,
      estado_laboral,
      habilitado,
      sort = 'created_at',
      order = 'desc',
      page = 1,
      limit = 10,
    } = query;
    const offset = (page - 1) * limit;

    let supabaseQuery = this.supabaseService
      .getClient()
      .from('egresados')
      .select(
        `
                id,
                nombre,
                apellido,
                correo_institucional,
                id_universitario,
                celular,
                habilitado,
                proceso_grado_completo,
                autoevaluacion_habilitada,
                autoevaluacion_completada,
                estado_laboral_id,
                created_at,
                carreras (
                    id,
                    nombre
                ),
                estados_laborales (
                    id,
                    nombre
                )
            `,
        { count: 'exact' },
      )
      .is('deleted_at', null);

    // Text search
    if (q) {
      const s = q.replace(/%/g, '\\%');
      supabaseQuery = supabaseQuery.or(
        `(nombre.ilike.%${s}%,apellido.ilike.%${s}%,correo_institucional.ilike.%${s}%)`,
      );
    }

    // Filters
    if (carrera) {
      supabaseQuery = supabaseQuery.eq('carrera_id', carrera);
    }

    if (estado_laboral) {
      supabaseQuery = supabaseQuery.eq('estado_laboral_id', estado_laboral);
    }

    if (habilitado !== undefined) {
      supabaseQuery = supabaseQuery.eq('habilitado', habilitado);
    }

    // Sorting
    supabaseQuery = supabaseQuery.order(sort, { ascending: order === 'asc' });

    // Pagination
    supabaseQuery = supabaseQuery.range(offset, offset + limit - 1);

    const { data, error, count } = await supabaseQuery;

    if (error) {
      this.logger.error(`Error in search: ${error.message}`);
      throw new InternalServerErrorException('Error en la búsqueda');
    }

    return {
      data,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
      },
    };
  }

  /**
   * Export egresados to Excel
   */
  async exportEgresadosExcel(filtros: FiltrosEgresadosDto): Promise<Buffer> {
    // Get all data (no pagination)
    const lista = await this.getListaEgresados({ ...filtros, limit: 10000, page: 1 });
    const data = lista.data || [];

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Egresados');

    // Define columns
    worksheet.columns = [
      { header: 'ID Universitario', key: 'id_universitario', width: 15 },
      { header: 'Nombre', key: 'nombre', width: 20 },
      { header: 'Apellido', key: 'apellido', width: 20 },
      { header: 'correo_institucional', key: 'correo_institucional', width: 35 },
      { header: 'Carrera', key: 'carrera', width: 35 },
      { header: 'Teléfono', key: 'celular', width: 15 },
      { header: 'Estado Laboral', key: 'estado_laboral', width: 20 },
      { header: 'Habilitado', key: 'habilitado', width: 12 },
      { header: 'Autoevaluación', key: 'autoevaluacion', width: 15 },
      { header: 'Fecha Registro', key: 'created_at', width: 20 },
    ];

    // Add data
    data.forEach((egresado) => {
      worksheet.addRow({
        id_universitario: egresado.id_universitario || 'N/A',
        nombre: egresado.nombre,
        apellido: egresado.apellido,
        correo_institucional: egresado.correo_institucional,
        carrera: (egresado.carreras as any)?.nombre || 'N/A',
        celular: egresado.celular || 'N/A',
        estado_laboral: (egresado.estados_laborales as any)?.nombre || 'N/A',
        habilitado: egresado.habilitado ? 'Sí' : 'No',
        autoevaluacion: egresado.autoevaluacion_completada ? 'Completada' : 'Pendiente',
        created_at: egresado.created_at
          ? new Date(egresado.created_at).toLocaleDateString('es-CO')
          : '',
      });
    });

    // Style header row
    worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } } as any;
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF003366' },
    } as any;
    worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' } as any;

    // Generate buffer
    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  /**
   * Export autoevaluaciones to Excel
   */
  async exportAutoevaluacionesExcel(): Promise<Buffer> {
    // Get all responses
    const { data, error } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select(
        `
                *,
                egresado:egresados(nombre, apellido, correo_institucional, id_universitario),
                pregunta:preguntas_autoevaluacion(texto, categoria, tipo)
            `,
      )
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Error fetching autoevaluaciones: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener autoevaluaciones');
    }

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Autoevaluaciones');

    // Define columns
    worksheet.columns = [
      { header: 'ID Universitario', key: 'id_universitario', width: 15 },
      { header: 'Egresado', key: 'egresado', width: 35 },
      { header: 'correo_institucional', key: 'correo_institucional', width: 35 },
      { header: 'Competencia', key: 'competencia', width: 30 },
      { header: 'Pregunta', key: 'pregunta', width: 60 },
      { header: 'Respuesta', key: 'respuesta', width: 15 },
      { header: 'Fecha', key: 'fecha', width: 20 },
    ];

    // Add data
    (data || []).forEach((resp) => {
      worksheet.addRow({
        id_universitario: resp.egresado?.id_universitario || 'N/A',
        egresado: `${resp.egresado?.nombre || ''} ${resp.egresado?.apellido || ''}`.trim(),
        correo_institucional: resp.egresado?.correo_institucional || 'N/A',
        competencia: resp.pregunta?.categoria || 'N/A',
        pregunta: resp.pregunta?.texto || 'N/A',
        respuesta: resp.respuesta_numerica ?? resp.respuesta_texto ?? 'N/A',
        fecha: resp.created_at ? new Date(resp.created_at).toLocaleDateString('es-CO') : '',
      });
    });

    // Style header row
    worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } } as any;
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF003366' },
    } as any;
    worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' } as any;

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  /**
   * Get list of egresados with graduation documents (Documentos de Grado), optionally filtered by career
   */
  async getPDFsUnificados(carrera?: string) {
    try {
      const client = this.supabaseService.getClient();

      // Query documentos_egresado table - showing ALL documents for now
      let query = client
        .from('documentos_egresado')
        .select(`
          id,
          egresado_id,
          tipo_documento,
          nombre_archivo,
          ruta_storage,
          created_at,
          egresados (
            id,
            nombre,
            apellido,
            correo_institucional,
            carrera_id,
            carreras (nombre)
          )
        `)
        // Temporarily removed filter to debug
        .order('created_at', { ascending: false });

      const { data, error } = await query;

      if (error) {
        this.logger.error(`Error fetching graduation documents: ${error.message}`);
        throw new InternalServerErrorException('Error al obtener documentos de grado');
      }

      // Filter by career if provided
      let filteredData = data || [];
      if (carrera) {
        filteredData = filteredData.filter(
          (doc: any) => doc.egresados?.carreras?.nombre === carrera
        );
      }

      // Group by career
      const groupedByCarrera = filteredData.reduce((acc: any, doc: any) => {
        const carreraName = doc.egresados?.carreras?.nombre || 'Sin carrera';

        if (!acc[carreraName]) {
          acc[carreraName] = [];
        }

        // Generate public URL from storage path
        const { data: urlData } = client.storage
          .from('egresados-documentos')
          .getPublicUrl(doc.ruta_storage);

        const publicUrl = urlData?.publicUrl || null;
        this.logger.log(`Generated URL for ${doc.nombre_archivo}: ${publicUrl}`);
        this.logger.log(`created_at value: ${doc.created_at}, type: ${typeof doc.created_at}`);

        acc[carreraName].push({
          id: doc.id,
          egresado_id: doc.egresado_id,
          egresado_nombre: `${doc.egresados?.nombre || ''} ${doc.egresados?.apellido || ''}`.trim(),
          egresado_correo: doc.egresados?.correo_institucional,
          tipo_documento: doc.tipo_documento,
          nombre_archivo: doc.nombre_archivo,
          url_publica: publicUrl,
          fecha_generacion: doc.created_at,
        });

        return acc;
      }, {});

      return {
        total: filteredData.length,
        por_carrera: Object.entries(groupedByCarrera).map(([carrera, documentos]) => ({
          carrera,
          total: (documentos as any[]).length,
          documentos,
        })),
      };
    } catch (error) {
      this.logger.error(`Error in getPDFsUnificados: ${error.message}`);
      throw error;
    }
  }

  /**
   * Download documento file from Supabase Storage
   */
  async downloadDocumento(documentoId: string) {
    try {
      const client = this.supabaseService.getClient();

      // Get documento info
      const { data: documento, error: docError } = await client
        .from('documentos_egresado')
        .select('ruta_storage, nombre_archivo, mime_type')
        .eq('id', documentoId)
        .single();

      if (docError || !documento) {
        this.logger.error(`Documento not found: ${documentoId}`);
        throw new NotFoundException('Documento no encontrado');
      }

      this.logger.log(`=== DOCUMENTO INFO ===`);
      this.logger.log(`ID: ${documentoId}`);
      this.logger.log(`Nombre archivo: ${documento.nombre_archivo}`);
      this.logger.log(`Ruta storage: "${documento.ruta_storage}"`);
      this.logger.log(`Mime type: ${documento.mime_type}`);
      this.logger.log(`======================`);
      this.logger.log(`Creating signed URL for path: ${documento.ruta_storage}`);

      // Create a signed URL (valid for 60 seconds)
      const { data: urlData, error: urlError } = await client.storage
        .from('egresados-documentos')
        .createSignedUrl(documento.ruta_storage, 60);

      if (urlError || !urlData) {
        this.logger.error(`Error creating signed URL: ${JSON.stringify(urlError)}`);
        throw new InternalServerErrorException('Error al generar URL de descarga');
      }

      this.logger.log(`Signed URL created: ${urlData.signedUrl}`);

      // Download file using fetch
      const response = await fetch(urlData.signedUrl);

      if (!response.ok) {
        this.logger.error(`HTTP error downloading file: ${response.status} ${response.statusText}`);
        throw new InternalServerErrorException(`Error HTTP ${response.status} al descargar archivo`);
      }

      const arrayBuffer = await response.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);

      this.logger.log(`File downloaded successfully, size: ${buffer.length} bytes`);

      return {
        buffer,
        filename: documento.nombre_archivo,
        mimeType: documento.mime_type || 'application/pdf',
      };
    } catch (error) {
      this.logger.error(`Error in downloadDocumento: ${error.message}`);
      throw error;
    }
  }



  // ==================== CRUD DE PREGUNTAS ====================

  async getPreguntas(moduloId?: string, activa?: boolean) {
    let query = this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*')
      .order('orden', { ascending: true });

    // NOTA: La columna modulo_id no existe en el schema actual de preguntas_autoevaluacion
    // Si necesitas filtrar por módulo, debes agregar esta columna a la tabla primero
    // if (moduloId) {
    //     query = query.eq('modulo_id', moduloId);
    // }

    if (activa !== undefined) {
      query = query.eq('activa', activa);
    }

    const { data, error } = await query;

    if (error) {
      this.logger.error(`Error fetching questions: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener preguntas');
    }

    return data;
  }

  async getPregunta(id: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) {
      throw new NotFoundException('Pregunta no encontrada');
    }

    return data;
  }

  async createPregunta(dto: CreatePreguntaDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .insert({
        ...dto,
        activa: dto.activa ?? true,
      })
      .select()
      .single();

    if (error) {
      this.logger.error(`Error creating question: ${error.message}`);
      throw new InternalServerErrorException('Error al crear pregunta');
    }

    this.logger.log(`Pregunta creada: ${data.id}`);
    return data;
  }

  async updatePregunta(id: string, dto: UpdatePreguntaDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .update(dto)
      .eq('id', id)
      .select()
      .single();

    if (error || !data) {
      throw new NotFoundException('Pregunta no encontrada');
    }

    this.logger.log(`Pregunta actualizada: ${id}`);
    return data;
  }

  async togglePregunta(id: string) {
    const pregunta = await this.getPregunta(id);

    const { data, error } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .update({ activa: !pregunta.activa })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new InternalServerErrorException('Error al actualizar pregunta');
    }

    this.logger.log(`Pregunta ${data.activa ? 'activada' : 'desactivada'}: ${id}`);
    return data;
  }

  // ==================== CRUD DE MÓDULOS ====================

  async getModulos(activo?: boolean) {
    let query = this.supabaseService
      .getClient()
      .from('modulos')
      .select('*')
      .order('orden', { ascending: true });

    if (activo !== undefined) {
      query = query.eq('activo', activo);
    }

    const { data, error } = await query;

    if (error) {
      this.logger.error(`Error fetching modules: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener módulos');
    }

    return data;
  }

  async getModulo(id: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) {
      throw new NotFoundException('Módulo no encontrado');
    }

    return data;
  }

  async createModulo(dto: CreateModuloDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .insert({
        ...dto,
        activo: dto.activo ?? true,
      })
      .select()
      .single();

    if (error) {
      this.logger.error(`Error creating module: ${error.message}`);
      throw new InternalServerErrorException('Error al crear módulo');
    }

    this.logger.log(`Módulo creado: ${data.id}`);
    return data;
  }

  async updateModulo(id: string, dto: UpdateModuloDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .update(dto)
      .eq('id', id)
      .select()
      .single();

    if (error || !data) {
      throw new NotFoundException('Módulo no encontrado');
    }

    this.logger.log(`Módulo actualizado: ${id}`);
    return data;
  }

  async toggleModulo(id: string) {
    const modulo = await this.getModulo(id);

    const { data, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .update({ activo: !modulo.activo })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new InternalServerErrorException('Error al actualizar módulo');
    }

    this.logger.log(`Módulo ${data.activo ? 'activado' : 'desactivado'}: ${id}`);
    return data;
  }
}

