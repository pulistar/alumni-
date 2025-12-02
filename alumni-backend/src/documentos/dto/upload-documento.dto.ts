import { IsString, IsEnum, IsOptional } from 'class-validator';

export enum TipoDocumento {
  MOMENTO_OLE = 'momento_ole',
  DATOS_EGRESADOS = 'datos_egresados',
  BOLSA_EMPLEO = 'bolsa_empleo',
  UNIFICADO = 'unificado',
  OTRO = 'otro',
}

export class UploadDocumentoDto {
  @IsEnum(TipoDocumento)
  tipo_documento: TipoDocumento;

  @IsString()
  @IsOptional()
  descripcion?: string;
}
