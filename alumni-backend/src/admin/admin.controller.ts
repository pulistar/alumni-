import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Query,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseFilePipe,
  FileTypeValidator,
  HttpCode,
  HttpStatus,
  Res,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AdminService } from './admin.service';
import { FiltrosEgresadosDto } from './dto/filtros-egresados.dto';
import { SearchEgresadosDto } from './dto/search-egresados.dto';
import { CreatePreguntaDto, UpdatePreguntaDto } from './dto/pregunta.dto';
import { CreateModuloDto, UpdateModuloDto } from './dto/modulo.dto';
import { CreateCarreraDto, UpdateCarreraDto } from './dto/carrera.dto';
import { CreateGradoAcademicoDto, UpdateGradoAcademicoDto } from './dto/grado-academico.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery, ApiConsumes, ApiBody } from '@nestjs/swagger';

@ApiTags('admin')
@ApiBearerAuth('JWT-auth')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'superadmin')
export class AdminController {
  constructor(private readonly adminService: AdminService) { }

  @Get('egresados/search')
  @ApiOperation({ summary: 'Búsqueda avanzada de egresados' })
  @ApiQuery({ name: 'q', required: false, description: 'Término de búsqueda' })
  @ApiQuery({ name: 'carrera', required: false, description: 'Filtrar por carrera' })
  @ApiQuery({ name: 'estado_laboral', required: false, description: 'Filtrar por estado laboral' })
  @ApiQuery({ name: 'habilitado', required: false, type: Boolean })
  @ApiQuery({ name: 'sort', required: false, description: 'Campo para ordenar' })
  @ApiQuery({ name: 'order', required: false, enum: ['asc', 'desc'] })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Resultados de búsqueda' })
  async searchEgresados(@Query() query: SearchEgresadosDto) {
    return this.adminService.searchEgresados(query);
  }

  @Get('egresados')
  @ApiOperation({ summary: 'Listar egresados con filtros' })
  @ApiResponse({ status: 200, description: 'Lista de egresados' })
  async getListaEgresados(@Query() filtros: FiltrosEgresadosDto) {
    return this.adminService.getListaEgresados(filtros);
  }

  @Get('egresados/:id')
  @ApiOperation({ summary: 'Obtener detalle de egresado' })
  @ApiResponse({ status: 200, description: 'Detalle del egresado' })
  async getDetalleEgresado(@Param('id') id: string) {
    return this.adminService.getDetalleEgresado(id);
  }

  @Get('egresados/:id/documentos')
  @ApiOperation({ summary: 'Obtener documentos de egresado' })
  @ApiResponse({ status: 200, description: 'Lista de documentos' })
  async getDocumentosEgresado(@Param('id') id: string) {
    return this.adminService.getDocumentosEgresado(id);
  }

  @Get('egresados/:id/autoevaluacion')
  @ApiOperation({ summary: 'Obtener respuestas de autoevaluación' })
  @ApiResponse({ status: 200, description: 'Respuestas de autoevaluación' })
  async getEgresadoAutoevaluacion(@Param('id') id: string) {
    return this.adminService.getRespuestasAutoevaluacion(id);
  }

  @Get('dashboard/stats')
  @ApiOperation({ summary: 'Obtener estadísticas del dashboard' })
  @ApiResponse({ status: 200, description: 'Estadísticas generales' })
  async getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('analytics/distribucion-carrera')
  @ApiOperation({ summary: 'Obtener distribución de egresados por carrera' })
  @ApiResponse({ status: 200, description: 'Distribución por carrera' })
  async getDistribucionCarrera() {
    return this.adminService.getDistribucionPorCarrera();
  }

  @Get('analytics/tasa-empleabilidad')
  @ApiOperation({ summary: 'Obtener tasa de empleabilidad general' })
  @ApiResponse({ status: 200, description: 'Tasa de empleabilidad' })
  async getTasaEmpleabilidad() {
    return this.adminService.getTasaEmpleabilidad();
  }

  @Get('analytics/empleabilidad-carrera')
  @ApiOperation({ summary: 'Obtener empleabilidad por carrera' })
  @ApiResponse({ status: 200, description: 'Empleabilidad por carrera' })
  async getEmpleabilidadCarrera() {
    return this.adminService.getEmpleabilidadPorCarrera();
  }

  @Get('analytics/embudo-proceso')
  @ApiOperation({ summary: 'Obtener embudo del proceso de grado' })
  @ApiResponse({ status: 200, description: 'Embudo de proceso' })
  async getEmbudoProceso() {
    return this.adminService.getEmbudoProceso();
  }

  @Get('analytics/radar-competencias')
  @ApiOperation({ summary: 'Obtener radar de competencias' })
  @ApiResponse({ status: 200, description: 'Radar de competencias' })
  async getRadarCompetencias() {
    return this.adminService.getRadarCompetencias();
  }

  @Patch('egresados/:id/habilitar')
  @ApiOperation({ summary: 'Habilitar/deshabilitar egresado' })
  @ApiResponse({ status: 200, description: 'Egresado actualizado' })
  @HttpCode(HttpStatus.OK)
  async habilitarEgresado(@Param('id') id: string, @Body('habilitado') habilitado: boolean) {
    return this.adminService.habilitarEgresado(id, habilitado);
  }

  @Post('egresados/habilitar-excel')
  @ApiOperation({ summary: 'Habilitar egresados desde archivo Excel' })
  @ApiResponse({ status: 200, description: 'Resultado de la carga' })
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('file'))
  async habilitarDesdeExcel(
    @CurrentUser() admin: any,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.adminService.habilitarDesdeExcel(file, admin.id);
  }

  @Get('reportes/egresados/excel')
  @ApiOperation({ summary: 'Exportar egresados a Excel' })
  @ApiResponse({ status: 200, description: 'Archivo Excel generado' })
  async exportEgresadosExcel(@Query() filtros: FiltrosEgresadosDto, @Res() res: any) {
    const buffer = await this.adminService.exportEgresadosExcel(filtros);

    res.set({
      'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename=egresados-${Date.now()}.xlsx`,
    });

    res.send(buffer);
  }

  @Get('reportes/autoevaluaciones/excel')
  @ApiOperation({ summary: 'Exportar autoevaluaciones a Excel' })
  @ApiResponse({ status: 200, description: 'Archivo Excel generado' })
  async exportAutoevaluacionesExcel(@Res() res: any) {
    const buffer = await this.adminService.exportAutoevaluacionesExcel();

    res.set({
      'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename=autoevaluaciones-${Date.now()}.xlsx`,
    });

    res.send(buffer);
  }

  @Get('reportes/estadisticas/excel')
  @ApiOperation({ summary: 'Exportar estadísticas completas a Excel' })
  @ApiResponse({ status: 200, description: 'Archivo Excel generado' })
  async exportEstadisticasExcel(@Res() res: any) {
    const buffer = await this.adminService.exportEstadisticasExcel();

    res.set({
      'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename=estadisticas-${Date.now()}.xlsx`,
    });

    res.send(buffer);
  }


  @Get('reportes/pdfs-unificados')
  @ApiOperation({ summary: 'Obtener lista de PDFs unificados por carrera' })
  @ApiQuery({ name: 'carrera', required: false, description: 'Filtrar por carrera' })
  @ApiResponse({ status: 200, description: 'Lista de egresados con PDF unificado' })
  async getPDFsUnificados(@Query('carrera') carrera?: string) {
    return this.adminService.getPDFsUnificados(carrera);
  }

  @Get('documentos/:documentoId/download')
  @ApiOperation({ summary: 'Descargar archivo de documento' })
  @ApiResponse({ status: 200, description: 'Archivo descargado' })
  async downloadDocumento(
    @Param('documentoId') documentoId: string,
    @Res() res: any,
  ) {
    const { buffer, filename, mimeType } = await this.adminService.downloadDocumento(documentoId);

    res.set({
      'Content-Type': mimeType || 'application/pdf',
      'Content-Disposition': `attachment; filename="${filename}"`,
      'Content-Length': buffer.length,
    });

    res.send(buffer);
  }

  // ==================== CRUD DE PREGUNTAS ====================

  @Get('preguntas')
  @ApiOperation({ summary: 'Listar todas las preguntas de autoevaluación' })
  @ApiQuery({ name: 'modulo_id', required: false, description: 'Filtrar por módulo' })
  @ApiQuery({ name: 'activa', required: false, type: Boolean, description: 'Filtrar por estado' })
  @ApiResponse({ status: 200, description: 'Lista de preguntas' })
  async getPreguntas(@Query('modulo_id') moduloId?: string, @Query('activa') activa?: boolean) {
    return this.adminService.getPreguntas(moduloId, activa);
  }

  @Get('preguntas/:id')
  @ApiOperation({ summary: 'Obtener una pregunta por ID' })
  @ApiResponse({ status: 200, description: 'Pregunta encontrada' })
  @ApiResponse({ status: 404, description: 'Pregunta no encontrada' })
  async getPregunta(@Param('id') id: string) {
    return this.adminService.getPregunta(id);
  }

  @Post('preguntas')
  @ApiOperation({ summary: 'Crear una nueva pregunta' })
  @ApiResponse({ status: 201, description: 'Pregunta creada exitosamente' })
  @HttpCode(HttpStatus.CREATED)
  async createPregunta(@Body() dto: CreatePreguntaDto) {
    return this.adminService.createPregunta(dto);
  }

  @Patch('preguntas/:id')
  @ApiOperation({ summary: 'Actualizar una pregunta' })
  @ApiResponse({ status: 200, description: 'Pregunta actualizada' })
  @ApiResponse({ status: 404, description: 'Pregunta no encontrada' })
  async updatePregunta(@Param('id') id: string, @Body() dto: UpdatePreguntaDto) {
    return this.adminService.updatePregunta(id, dto);
  }

  @Patch('preguntas/:id/toggle')
  @ApiOperation({ summary: 'Activar/desactivar una pregunta' })
  @ApiResponse({ status: 200, description: 'Estado actualizado' })
  async togglePregunta(@Param('id') id: string) {
    return this.adminService.togglePregunta(id);
  }

  // ==================== CRUD DE MÓDULOS ====================

  @Get('modulos')
  @ApiOperation({ summary: 'Listar todos los módulos de autoevaluación' })
  @ApiQuery({ name: 'activo', required: false, type: Boolean })
  @ApiResponse({ status: 200, description: 'Lista de módulos' })
  async getModulos(@Query('activo') activo?: boolean) {
    return this.adminService.getModulos(activo);
  }

  @Get('modulos/:id')
  @ApiOperation({ summary: 'Obtener un módulo por ID' })
  @ApiResponse({ status: 200, description: 'Módulo encontrado' })
  @ApiResponse({ status: 404, description: 'Módulo no encontrado' })
  async getModulo(@Param('id') id: string) {
    return this.adminService.getModulo(id);
  }

  @Post('modulos')
  @ApiOperation({ summary: 'Crear un nuevo módulo' })
  @ApiResponse({ status: 201, description: 'Módulo creado exitosamente' })
  @HttpCode(HttpStatus.CREATED)
  async createModulo(@Body() dto: CreateModuloDto) {
    return this.adminService.createModulo(dto);
  }

  @Patch('modulos/:id')
  @ApiOperation({ summary: 'Actualizar un módulo' })
  @ApiResponse({ status: 200, description: 'Módulo actualizado' })
  @ApiResponse({ status: 404, description: 'Módulo no encontrado' })
  async updateModulo(@Param('id') id: string, @Body() dto: UpdateModuloDto) {
    return this.adminService.updateModulo(id, dto);
  }

  @Patch('modulos/:id/toggle')
  @ApiOperation({ summary: 'Activar/desactivar un módulo' })
  @ApiResponse({ status: 200, description: 'Estado actualizado' })
  async toggleModulo(@Param('id') id: string) {
    return this.adminService.toggleModulo(id);
  }

  // ==================== CRUD DE CARRERAS ====================

  @Get('carreras')
  @ApiOperation({ summary: 'Listar todas las carreras' })
  @ApiQuery({ name: 'activa', required: false, type: Boolean })
  @ApiResponse({ status: 200, description: 'Lista de carreras' })
  async getCarreras(@Query('activa') activa?: boolean) {
    return this.adminService.getCarreras(activa);
  }

  @Get('carreras/:id')
  @ApiOperation({ summary: 'Obtener una carrera por ID' })
  @ApiResponse({ status: 200, description: 'Carrera encontrada' })
  @ApiResponse({ status: 404, description: 'Carrera no encontrada' })
  async getCarrera(@Param('id') id: string) {
    return this.adminService.getCarrera(id);
  }

  @Post('carreras')
  @ApiOperation({ summary: 'Crear una nueva carrera' })
  @ApiResponse({ status: 201, description: 'Carrera creada exitosamente' })
  @HttpCode(HttpStatus.CREATED)
  async createCarrera(@Body() dto: CreateCarreraDto) {
    return this.adminService.createCarrera(dto);
  }

  @Patch('carreras/:id')
  @ApiOperation({ summary: 'Actualizar una carrera' })
  @ApiResponse({ status: 200, description: 'Carrera actualizada' })
  @ApiResponse({ status: 404, description: 'Carrera no encontrada' })
  async updateCarrera(@Param('id') id: string, @Body() dto: UpdateCarreraDto) {
    return this.adminService.updateCarrera(id, dto);
  }

  @Patch('carreras/:id/toggle')
  @ApiOperation({ summary: 'Activar/desactivar una carrera' })
  @ApiResponse({ status: 200, description: 'Estado actualizado' })
  async toggleCarrera(@Param('id') id: string) {
    return this.adminService.toggleCarrera(id);
  }

  // ==================== CRUD DE GRADOS ACADÉMICOS ====================

  @Get('grados-academicos')
  @ApiOperation({ summary: 'Listar todos los grados académicos' })
  @ApiQuery({ name: 'activo', required: false, type: Boolean })
  @ApiResponse({ status: 200, description: 'Lista de grados académicos' })
  async getGradosAcademicos(@Query('activo') activo?: boolean) {
    return this.adminService.getGradosAcademicos(activo);
  }

  @Get('grados-academicos/:id')
  @ApiOperation({ summary: 'Obtener un grado académico por ID' })
  @ApiResponse({ status: 200, description: 'Grado académico encontrado' })
  @ApiResponse({ status: 404, description: 'Grado académico no encontrado' })
  async getGradoAcademico(@Param('id') id: string) {
    return this.adminService.getGradoAcademico(id);
  }

  @Post('grados-academicos')
  @ApiOperation({ summary: 'Crear un nuevo grado académico' })
  @ApiResponse({ status: 201, description: 'Grado académico creado exitosamente' })
  @HttpCode(HttpStatus.CREATED)
  async createGradoAcademico(@Body() dto: CreateGradoAcademicoDto) {
    return this.adminService.createGradoAcademico(dto);
  }

  @Patch('grados-academicos/:id')
  @ApiOperation({ summary: 'Actualizar un grado académico' })
  @ApiResponse({ status: 200, description: 'Grado académico actualizado' })
  @ApiResponse({ status: 404, description: 'Grado académico no encontrado' })
  async updateGradoAcademico(@Param('id') id: string, @Body() dto: UpdateGradoAcademicoDto) {
    return this.adminService.updateGradoAcademico(id, dto);
  }

  @Patch('grados-academicos/:id/toggle')
  @ApiOperation({ summary: 'Activar/desactivar un grado académico' })
  @ApiResponse({ status: 200, description: 'Estado actualizado' })
  async toggleGradoAcademico(@Param('id') id: string) {
    return this.adminService.toggleGradoAcademico(id);
  }

  @Post('invitaciones/excel')
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: 'Enviar invitaciones masivas desde Excel' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  async sendInvitationsExcel(@UploadedFile() file: Express.Multer.File) {
    return this.adminService.sendInvitationsFromExcel(file);
  }
}
