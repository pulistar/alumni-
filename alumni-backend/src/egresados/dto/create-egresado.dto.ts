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
  telefono: string;

  @IsString()
  @IsOptional()
  telefono_alternativo?: string;

  @IsString()
  @IsOptional()
  direccion?: string;

  @IsString()
  ciudad: string;

  @IsString()
  @IsOptional()
  pais?: string;

  @IsUUID()
  @IsOptional()
  estado_laboral_id?: string;

  @IsString()
  @IsOptional()
  empresa_actual?: string;

  @IsString()
  @IsOptional()
  cargo_actual?: string;

  @IsDateString()
  @IsOptional()
  fecha_graduacion?: string;

  @IsString()
  @IsOptional()
  semestre_graduacion?: string;

  @IsString()
  @IsOptional()
  anio_graduacion?: number;
}
