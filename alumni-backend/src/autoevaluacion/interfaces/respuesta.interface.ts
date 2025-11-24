export interface IRespuesta {
  id: string;
  egresado_id: string;
  pregunta_id: string;
  respuesta_texto?: string;
  respuesta_numerica?: number;
  created_at: Date;
  updated_at: Date;
}
