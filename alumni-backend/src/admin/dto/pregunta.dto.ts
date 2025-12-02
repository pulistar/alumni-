import { IsString, IsOptional, IsBoolean, IsInt, IsEnum, IsNotEmpty } from 'class-validator';
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
  @IsNotEmpty()
  texto: string;

  @ApiProperty({ enum: TipoPregunta, description: 'Tipo de pregunta', default: 'likert' })
  @IsEnum(TipoPregunta)
  @IsNotEmpty()
  tipo: TipoPregunta;

  @ApiPropertyOptional({
    description: 'Opciones de respuesta en formato JSON (para preguntas de selección múltiple)',
  })
  @IsNotEmpty()
  opciones: any;

  @ApiProperty({ description: 'Orden de la pregunta' })
  @IsInt()
  @Type(() => Number)
  @IsNotEmpty()
  orden: number;

  @ApiPropertyOptional({
    description: 'Categoría de la pregunta (ej: competencias, empleabilidad)',
  })
  @IsString()
  @IsNotEmpty()
  categoria: string;

  @ApiPropertyOptional({ description: 'Si la pregunta está activa', default: true })
  @IsBoolean()
  @IsNotEmpty()
  activa: boolean;
}

export class UpdatePreguntaDto {
  @ApiPropertyOptional({ description: 'Texto de la pregunta' })
  @IsString()
  @IsNotEmpty()
  texto: string;

  @ApiPropertyOptional({ enum: TipoPregunta, description: 'Tipo de pregunta' })
  @IsEnum(TipoPregunta)
  @IsNotEmpty()
  tipo: TipoPregunta;

  @ApiPropertyOptional({ description: 'Opciones de respuesta en formato JSON' })
  @IsNotEmpty()
  opciones: any;

  @ApiPropertyOptional({ description: 'Orden de la pregunta' })
  @IsInt()
  @Type(() => Number)
  @IsNotEmpty()
  orden: number;

  @ApiPropertyOptional({ description: 'Categoría de la pregunta' })
  @IsString()
  @IsNotEmpty()
  categoria: string;

  @ApiPropertyOptional({ description: 'Si la pregunta está activa' })
  @IsBoolean()
  @IsNotEmpty()
  activa: boolean;
}
