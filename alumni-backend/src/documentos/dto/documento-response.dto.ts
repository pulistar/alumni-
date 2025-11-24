export class DocumentoResponseDto {
  id: string;
  nombre_archivo: string;
  tipo_documento: string;
  tamano_bytes: number;
  mime_type: string;
  url_descarga?: string;
  created_at: Date;
}
