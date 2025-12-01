import { IsString, IsInt, IsBoolean, IsOptional, MaxLength, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateGradoAcademicoDto {
    @ApiProperty({ description: 'Nombre del grado académico', example: 'Pregrado' })
    @IsString()
    @MaxLength(100)
    nombre: string;

    @ApiPropertyOptional({ description: 'Código del grado', example: 'PREG' })
    @IsString()
    @IsOptional()
    @MaxLength(20)
    codigo?: string;

    @ApiPropertyOptional({
        description: 'Nivel jerárquico del grado (1-7)',
        example: 4,
        minimum: 0,
        maximum: 7
    })
    @IsInt()
    @IsOptional()
    @Min(0)
    @Max(7)
    nivel?: number;

    @ApiPropertyOptional({ description: 'Si el grado está activo', example: true, default: true })
    @IsBoolean()
    @IsOptional()
    activo?: boolean;
}

export class UpdateGradoAcademicoDto {
    @ApiPropertyOptional({ description: 'Nombre del grado académico' })
    @IsString()
    @IsOptional()
    @MaxLength(100)
    nombre?: string;

    @ApiPropertyOptional({ description: 'Código del grado' })
    @IsString()
    @IsOptional()
    @MaxLength(20)
    codigo?: string;

    @ApiPropertyOptional({ description: 'Nivel jerárquico del grado (1-7)' })
    @IsInt()
    @IsOptional()
    @Min(0)
    @Max(7)
    nivel?: number;

    @ApiPropertyOptional({ description: 'Si el grado está activo' })
    @IsBoolean()
    @IsOptional()
    activo?: boolean;
}
