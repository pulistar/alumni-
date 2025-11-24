import {
  Injectable,
  Logger,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CrearNotificacionDto, NotificacionResponseDto } from './dto/notificacion.dto';

@Injectable()
export class NotificacionesService {
  private readonly logger = new Logger(NotificacionesService.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Create a new notification
   */
  async crear(dto: CrearNotificacionDto): Promise<void> {
    try {
      const { error } = await this.supabaseService.getClient().from('notificaciones').insert({
        egresado_id: dto.egresado_id,
        titulo: dto.titulo,
        mensaje: dto.mensaje,
        tipo: dto.tipo,
        url_accion: dto.url_accion,
        leida: false,
      });

      if (error) {
        this.logger.error(`Error creating notification: ${error.message}`);
        // Don't throw - notifications are non-critical
      } else {
        this.logger.log(`Notification created for egresado ${dto.egresado_id}: ${dto.titulo}`);
      }
    } catch (error) {
      this.logger.error(`Failed to create notification: ${error.message}`);
      // Don't throw - notifications are non-critical
    }
  }

  /**
   * List all notifications for an egresado
   */
  async listar(egresadoId: string): Promise<NotificacionResponseDto[]> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('notificaciones')
      .select('*')
      .eq('egresado_id', egresadoId)
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Error fetching notifications: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener notificaciones');
    }

    return data || [];
  }

  /**
   * Count unread notifications
   */
  async contarNoLeidas(egresadoId: string): Promise<{ total_no_leidas: number }> {
    const { count, error } = await this.supabaseService
      .getClient()
      .from('notificaciones')
      .select('*', { count: 'exact', head: true })
      .eq('egresado_id', egresadoId)
      .eq('leida', false);

    if (error) {
      this.logger.error(`Error counting notifications: ${error.message}`);
      throw new InternalServerErrorException('Error al contar notificaciones');
    }

    return { total_no_leidas: count || 0 };
  }

  /**
   * Mark a notification as read
   */
  async marcarComoLeida(notificacionId: string, egresadoId: string): Promise<void> {
    const { error } = await this.supabaseService
      .getClient()
      .from('notificaciones')
      .update({ leida: true })
      .eq('id', notificacionId)
      .eq('egresado_id', egresadoId);

    if (error) {
      this.logger.error(`Error marking notification as read: ${error.message}`);
      throw new InternalServerErrorException('Error al marcar notificación como leída');
    }

    this.logger.log(`Notification ${notificacionId} marked as read`);
  }

  /**
   * Mark all notifications as read
   */
  async marcarTodasComoLeidas(egresadoId: string): Promise<void> {
    const { error } = await this.supabaseService
      .getClient()
      .from('notificaciones')
      .update({ leida: true })
      .eq('egresado_id', egresadoId)
      .eq('leida', false);

    if (error) {
      this.logger.error(`Error marking all notifications as read: ${error.message}`);
      throw new InternalServerErrorException('Error al marcar todas como leídas');
    }

    this.logger.log(`All notifications marked as read for egresado ${egresadoId}`);
  }

  /**
   * Delete a notification
   */
  async eliminar(notificacionId: string, egresadoId: string): Promise<void> {
    const { error } = await this.supabaseService
      .getClient()
      .from('notificaciones')
      .delete()
      .eq('id', notificacionId)
      .eq('egresado_id', egresadoId);

    if (error) {
      this.logger.error(`Error deleting notification: ${error.message}`);
      throw new InternalServerErrorException('Error al eliminar notificación');
    }

    this.logger.log(`Notification ${notificacionId} deleted`);
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
