import { IsOptional, IsString, IsBoolean, IsIn, IsInt, Min, Max } from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SearchEgresadosDto {
  @ApiPropertyOptional({ description: 'Término de búsqueda (nombre, apellido, correo)' })
  @IsOptional()
  @IsString()
  q?: string;

  @ApiPropertyOptional({ description: 'Filtrar por ID de carrera' })
  @IsOptional()
  @IsString()
  carrera?: string;

  @ApiPropertyOptional({ description: 'Filtrar por estado laboral' })
  @IsOptional()
  @IsString()
  estado_laboral?: string;

  @ApiPropertyOptional({ description: 'Filtrar por estado de habilitación' })
  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === 'true' || value === true)
  habilitado?: boolean;

  @ApiPropertyOptional({
    description: 'Campo para ordenar',
    enum: ['nombre', 'apellido', 'created_at', 'fecha_registro'],
  })
  @IsOptional()
  @IsString()
  sort?: string;

  @ApiPropertyOptional({ description: 'Orden', enum: ['asc', 'desc'] })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  order?: 'asc' | 'desc';

  @ApiPropertyOptional({ description: 'Número de página', minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({
    description: 'Resultados por página',
    minimum: 1,
    maximum: 100,
    default: 10,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;
}
