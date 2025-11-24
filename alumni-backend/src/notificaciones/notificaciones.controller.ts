import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { NotificacionesService } from './notificaciones.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ICurrentUser } from '../auth/interfaces/current-user.interface';

@Controller('notificaciones')
@UseGuards(SupabaseAuthGuard)
export class NotificacionesController {
  constructor(private readonly notificacionesService: NotificacionesService) {}

  @Get()
  async listar(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.notificacionesService.getEgresadoIdByUid(user.id);
    return this.notificacionesService.listar(egresadoId);
  }

  @Get('no-leidas/count')
  async contarNoLeidas(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.notificacionesService.getEgresadoIdByUid(user.id);
    return this.notificacionesService.contarNoLeidas(egresadoId);
  }

  @Patch(':id/leer')
  @HttpCode(HttpStatus.OK)
  async marcarComoLeida(@Param('id') id: string, @CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.notificacionesService.getEgresadoIdByUid(user.id);
    await this.notificacionesService.marcarComoLeida(id, egresadoId);
    return { message: 'Notificación marcada como leída' };
  }

  @Patch('leer-todas')
  @HttpCode(HttpStatus.OK)
  async marcarTodasComoLeidas(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.notificacionesService.getEgresadoIdByUid(user.id);
    await this.notificacionesService.marcarTodasComoLeidas(egresadoId);
    return { message: 'Todas las notificaciones marcadas como leídas' };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async eliminar(@Param('id') id: string, @CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.notificacionesService.getEgresadoIdByUid(user.id);
    await this.notificacionesService.eliminar(id, egresadoId);
    return { message: 'Notificación eliminada' };
  }
}
