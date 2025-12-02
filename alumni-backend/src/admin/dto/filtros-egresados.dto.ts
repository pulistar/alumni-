import { IsOptional, IsBoolean, IsString, IsUUID, IsInt, Min, IsNotEmpty } from 'class-validator';
import { Type } from 'class-transformer';

export class FiltrosEgresadosDto {
  @IsUUID()
  @IsOptional()
  carrera_id: string;

  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  habilitado: boolean;

  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  proceso_grado_completo: boolean;

  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  autoevaluacion_completada: boolean;

  @IsString()
  @IsOptional()
  search: string; // Buscar por nombre, correo, id_universitario

  @IsInt()
  @Min(1)
  @Type(() => Number)
  @IsOptional()
  page: number;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  @IsOptional()
  limit: number;
}
