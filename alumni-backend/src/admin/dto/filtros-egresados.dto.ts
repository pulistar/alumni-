import { IsOptional, IsBoolean, IsString, IsUUID, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class FiltrosEgresadosDto {
  @IsOptional()
  @IsUUID()
  carrera_id?: string;

  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  habilitado?: boolean;

  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  proceso_grado_completo?: boolean;

  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  autoevaluacion_completada?: boolean;

  @IsOptional()
  @IsString()
  search?: string; // Buscar por nombre, correo, id_universitario

  @IsOptional()
  @IsInt()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;
}
