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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';

@ApiTags('admin')
@ApiBearerAuth('JWT-auth')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

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
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new FileTypeValidator({
            fileType: /(vnd\.openxmlformats-officedocument\.spreadsheetml\.sheet|vnd\.ms-excel)$/,
          }),
        ],
      }),
    )
    file: Express.Multer.File,
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
}
