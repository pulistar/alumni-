export class NotificacionResponseDto {
  id: string;
  titulo: string;
  mensaje: string;
  tipo: string;
  leida: boolean;
  url_accion?: string;
  created_at: Date;
}

export class CrearNotificacionDto {
  egresado_id: string;
  titulo: string;
  mensaje: string;
  tipo: 'habilitacion' | 'documento' | 'autoevaluacion' | 'general';
  url_accion?: string;
}
