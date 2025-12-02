import { IsOptional, IsString, IsBoolean, IsIn, IsInt, Min, Max, IsNotEmpty } from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SearchEgresadosDto {
  @ApiPropertyOptional({ description: 'Término de búsqueda (nombre, apellido, correo)' })
  @IsString()
  @IsOptional()
  q: string;

  @ApiPropertyOptional({ description: 'Filtrar por ID de carrera' })
  @IsString()
  @IsOptional()
  carrera: string;

  @ApiPropertyOptional({ description: 'Filtrar por estado laboral' })
  @IsString()
  @IsOptional()
  estado_laboral: string;

  @ApiPropertyOptional({ description: 'Filtrar por estado de habilitación' })
  @IsBoolean()
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  habilitado: boolean;

  @ApiPropertyOptional({
    description: 'Campo para ordenar',
    enum: ['nombre', 'apellido', 'created_at', 'fecha_registro'],
  })
  @IsString()
  @IsOptional()
  sort: string;

  @ApiPropertyOptional({ description: 'Orden', enum: ['asc', 'desc'] })
  @IsIn(['asc', 'desc'])
  @IsOptional()
  order: 'asc' | 'desc';

  @ApiPropertyOptional({ description: 'Número de página', minimum: 1, default: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page: number;

  @ApiPropertyOptional({
    description: 'Resultados por página',
    minimum: 1,
    maximum: 100,
    default: 10,
  })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit: number;
}
