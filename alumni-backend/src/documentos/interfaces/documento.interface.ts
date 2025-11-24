export interface IDocumento {
  id: string;
  egresado_id: string;
  tipo_documento: string;
  nombre_archivo: string;
  ruta_storage: string;
  tamano_bytes: number;
  mime_type: string;
  es_unificado: boolean;
  created_at: Date;
}
