import { IsString, IsOptional, IsUUID, IsDateString } from 'class-validator';

export class CreateEgresadoDto {
  @IsString()
  nombre: string;

  @IsString()
  apellido: string;

  @IsString()
  id_universitario: string;

  @IsUUID()
  carrera_id: string;

  @IsString()
  celular: string;

  @IsString()
  @IsOptional()
  telefono_alternativo?: string;

  @IsString()
  correo_personal: string;

  @IsUUID()
  tipo_documento_id: string;

  @IsString()
  documento: string;

  @IsString()
  lugar_expedicion: string;

  @IsUUID()
  grado_academico_id: string;
}
