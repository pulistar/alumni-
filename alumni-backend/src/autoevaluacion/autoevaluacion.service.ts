import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
  InternalServerErrorException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { GuardarRespuestaDto } from './dto/respuesta.dto';
import { ProgresoResponseDto } from './dto/progreso-response.dto';
import { IPreguntaConRespuesta } from './interfaces/pregunta.interface';
import { NotificacionesService } from '../notificaciones/notificaciones.service';
import { MailService } from '../mail/mail.service';

@Injectable()
export class AutoevaluacionService {
  private readonly logger = new Logger(AutoevaluacionService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificacionesService: NotificacionesService,
    private readonly mailService: MailService,
  ) {}

  /**
   * Get all active questions with user's previous answers
   */
  async getPreguntas(egresadoId: string): Promise<IPreguntaConRespuesta[]> {
    // Verify autoevaluacion is enabled
    await this.verificarHabilitacion(egresadoId);

    // Get all active questions
    const { data: preguntas, error: preguntasError } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*')
      .eq('activa', true)
      .order('orden', { ascending: true });

    if (preguntasError) {
      this.logger.error(`Error fetching questions: ${preguntasError.message}`);
      throw new InternalServerErrorException('Error al obtener preguntas');
    }

    // Get user's answers
    const { data: respuestas } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select('*')
      .eq('egresado_id', egresadoId);

    // Map answers to questions
    const preguntasConRespuestas: IPreguntaConRespuesta[] = (preguntas || []).map((pregunta) => {
      const respuesta = respuestas?.find((r) => r.pregunta_id === pregunta.id);
      return {
        ...pregunta,
        respuesta: respuesta
          ? {
              id: respuesta.id,
              respuesta_texto: respuesta.respuesta_texto,
              respuesta_numerica: respuesta.respuesta_numerica,
            }
          : undefined,
      };
    });

    return preguntasConRespuestas;
  }

  /**
   * Save or update a single answer
   */
  async guardarRespuesta(egresadoId: string, dto: GuardarRespuestaDto) {
    // Verify autoevaluacion is enabled
    await this.verificarHabilitacion(egresadoId);

    // Get question to validate
    const { data: pregunta, error: preguntaError } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*')
      .eq('id', dto.pregunta_id)
      .eq('activa', true)
      .single();

    if (preguntaError || !pregunta) {
      throw new NotFoundException('Pregunta no encontrada o inactiva');
    }

    // Validate answer type
    this.validarTipoRespuesta(pregunta, dto);

    // Check if answer already exists
    const { data: respuestaExistente } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select('*')
      .eq('egresado_id', egresadoId)
      .eq('pregunta_id', dto.pregunta_id)
      .single();

    if (respuestaExistente) {
      // Update existing answer
      const { data, error } = await this.supabaseService
        .getClient()
        .from('respuestas_autoevaluacion')
        .update({
          respuesta_texto: dto.respuesta_texto,
          respuesta_numerica: dto.respuesta_numerica,
        })
        .eq('id', respuestaExistente.id)
        .select()
        .single();

      if (error) {
        this.logger.error(`Error updating answer: ${error.message}`);
        throw new InternalServerErrorException('Error al actualizar respuesta');
      }

      this.logger.log(`Answer updated for question ${dto.pregunta_id}`);
      return data;
    } else {
      // Create new answer
      const { data, error } = await this.supabaseService
        .getClient()
        .from('respuestas_autoevaluacion')
        .insert({
          egresado_id: egresadoId,
          pregunta_id: dto.pregunta_id,
          respuesta_texto: dto.respuesta_texto,
          respuesta_numerica: dto.respuesta_numerica,
        })
        .select()
        .single();

      if (error) {
        this.logger.error(`Error creating answer: ${error.message}`);
        throw new InternalServerErrorException('Error al guardar respuesta');
      }

      this.logger.log(`Answer created for question ${dto.pregunta_id}`);
      return data;
    }
  }

  /**
   * Get progress of autoevaluacion
   */
  async getProgreso(egresadoId: string): Promise<ProgresoResponseDto> {
    // Count total active questions
    const { count: totalPreguntas, error: preguntasError } = await this.supabaseService
      .getClient()
      .from('preguntas_autoevaluacion')
      .select('*', { count: 'exact', head: true })
      .eq('activa', true);

    if (preguntasError) {
      this.logger.error(`Error counting questions: ${preguntasError.message}`);
      throw new InternalServerErrorException('Error al calcular progreso');
    }

    // Count answered questions
    const { count: preguntasRespondidas, error: respuestasError } = await this.supabaseService
      .getClient()
      .from('respuestas_autoevaluacion')
      .select('*', { count: 'exact', head: true })
      .eq('egresado_id', egresadoId);

    if (respuestasError) {
      this.logger.error(`Error counting answers: ${respuestasError.message}`);
      throw new InternalServerErrorException('Error al calcular progreso');
    }

    const total = totalPreguntas || 0;
    const respondidas = preguntasRespondidas || 0;
    const porcentaje = total > 0 ? Math.round((respondidas / total) * 100) : 0;

    return {
      total_preguntas: total,
      preguntas_respondidas: respondidas,
      porcentaje_completado: porcentaje,
      completada: porcentaje === 100,
    };
  }

  /**
   * Mark autoevaluacion as completed
   */
  async marcarComoCompletada(egresadoId: string) {
    // Verify all questions are answered
    const progreso = await this.getProgreso(egresadoId);

    if (progreso.porcentaje_completado < 100) {
      throw new BadRequestException(
        `Debes responder todas las preguntas. Progreso actual: ${progreso.porcentaje_completado}%`,
      );
    }

    // Update egresado profile
    const { error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .update({
        autoevaluacion_completada: true,
      })
      .eq('id', egresadoId);

    if (error) {
      this.logger.error(`Error marking as completed: ${error.message}`);
      throw new InternalServerErrorException('Error al marcar como completada');
    }

    this.logger.log(`✅ Autoevaluacion completed for egresado: ${egresadoId}`);

    // Create notification
    await this.notificacionesService.crear({
      egresado_id: egresadoId,
      titulo: '¡Felicidades!',
      mensaje: 'Has completado tu autoevaluación exitosamente.',
      tipo: 'autoevaluacion',
      url_accion: '/autoevaluacion',
    });

    // Send email notification
    try {
      // Get egresado info for email
      const { data: egresado } = await this.supabaseService
        .getClient()
        .from('egresados')
        .select('correo_institucional, nombre, apellido')
        .eq('id', egresadoId)
        .single();

      if (egresado) {
        await this.mailService.sendAutoevaluacionCompletada(
          egresado.correo_institucional,
          `${egresado.nombre} ${egresado.apellido}`,
        );
        this.logger.log(`Autoevaluacion email sent to ${egresado.correo_institucional}`);
      }
    } catch (error) {
      this.logger.error(`Failed to send autoevaluacion email: ${error.message}`);
    }

    return {
      message: 'Autoevaluación completada exitosamente',
      completada: true,
    };
  }

  /**
   * Verify that autoevaluacion is enabled for the egresado
   */
  private async verificarHabilitacion(egresadoId: string) {
    const { data: egresado, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('autoevaluacion_habilitada')
      .eq('id', egresadoId)
      .single();

    if (error || !egresado) {
      throw new NotFoundException('Perfil de egresado no encontrado');
    }

    if (!egresado.autoevaluacion_habilitada) {
      throw new ForbiddenException(
        'Debes subir los 3 documentos requeridos antes de acceder a la autoevaluación',
      );
    }
  }

  /**
   * Validate answer type matches question type
   */
  private validarTipoRespuesta(pregunta: any, dto: GuardarRespuestaDto) {
    if (pregunta.tipo === 'likert') {
      if (!dto.respuesta_numerica) {
        throw new BadRequestException('Pregunta tipo likert requiere respuesta numérica');
      }
      if (dto.respuesta_numerica < 1 || dto.respuesta_numerica > 5) {
        throw new BadRequestException('Respuesta likert debe estar entre 1 y 5');
      }
    } else if (pregunta.tipo === 'texto') {
      if (!dto.respuesta_texto) {
        throw new BadRequestException('Pregunta tipo texto requiere respuesta de texto');
      }
    }
  }

  /**
   * Get egresado ID from Supabase Auth UID
   */
  async getEgresadoIdByUid(uid: string): Promise<string> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id')
      .eq('uid', uid)
      .single();

    if (error || !data) {
      throw new NotFoundException('Perfil de egresado no encontrado');
    }

    return data.id;
  }
}

