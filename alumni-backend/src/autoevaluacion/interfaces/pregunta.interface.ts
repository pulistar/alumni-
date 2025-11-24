export interface IPregunta {
  id: string;
  texto: string;
  tipo: 'likert' | 'texto' | 'multiple';
  orden: number;
  categoria: string;
  activa: boolean;
  created_at: Date;
}

export interface IPreguntaConRespuesta extends IPregunta {
  respuesta?: {
    id: string;
    respuesta_texto?: string;
    respuesta_numerica?: number;
  };
}
