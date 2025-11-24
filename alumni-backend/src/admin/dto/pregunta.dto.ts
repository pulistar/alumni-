import { IsString, IsOptional, IsBoolean, IsInt, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export enum TipoPregunta {
  LIKERT = 'likert',
  TEXTO = 'texto',
  MULTIPLE = 'multiple',
}

export class CreatePreguntaDto {
  @ApiProperty({ description: 'Texto de la pregunta' })
  @IsString()
  texto: string;

  @ApiProperty({ enum: TipoPregunta, description: 'Tipo de pregunta', default: 'likert' })
  @IsEnum(TipoPregunta)
  tipo: TipoPregunta;

  @ApiPropertyOptional({
    description: 'Opciones de respuesta en formato JSON (para preguntas de selección múltiple)',
  })
  @IsOptional()
  opciones?: any;

  @ApiProperty({ description: 'Orden de la pregunta' })
  @IsInt()
  @Type(() => Number)
  orden: number;

  @ApiPropertyOptional({
    description: 'Categoría de la pregunta (ej: competencias, empleabilidad)',
  })
  @IsOptional()
  @IsString()
  categoria?: string;

  @ApiPropertyOptional({ description: 'Si la pregunta está activa', default: true })
  @IsOptional()
  @IsBoolean()
  activa?: boolean;
}

export class UpdatePreguntaDto {
  @ApiPropertyOptional({ description: 'Texto de la pregunta' })
  @IsOptional()
  @IsString()
  texto?: string;

  @ApiPropertyOptional({ enum: TipoPregunta, description: 'Tipo de pregunta' })
  @IsOptional()
  @IsEnum(TipoPregunta)
  tipo?: TipoPregunta;

  @ApiPropertyOptional({ description: 'Opciones de respuesta en formato JSON' })
  @IsOptional()
  opciones?: any;

  @ApiPropertyOptional({ description: 'Orden de la pregunta' })
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  orden?: number;

  @ApiPropertyOptional({ description: 'Categoría de la pregunta' })
  @IsOptional()
  @IsString()
  categoria?: string;

  @ApiPropertyOptional({ description: 'Si la pregunta está activa' })
  @IsOptional()
  @IsBoolean()
  activa?: boolean;
}
