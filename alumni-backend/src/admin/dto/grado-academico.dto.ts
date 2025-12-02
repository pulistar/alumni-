import { IsString, IsInt, IsBoolean, IsOptional, MaxLength, Min, Max, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateGradoAcademicoDto {
    @ApiProperty({ description: 'Nombre del grado académico', example: 'Pregrado' })
    @IsString()
    @MaxLength(100)
    @IsNotEmpty()
    nombre: string;

    @ApiPropertyOptional({ description: 'Código del grado', example: 'PREG' })
    @IsString()
    @MaxLength(20)
    @IsNotEmpty()
    codigo: string;

    @ApiPropertyOptional({
        description: 'Nivel jerárquico del grado (1-7)',
        example: 4,
        minimum: 0,
        maximum: 7
    })
    @IsInt()
    @Min(0)
    @Max(7)
    @IsNotEmpty()
    nivel: number;

    @ApiPropertyOptional({ description: 'Si el grado está activo', example: true, default: true })
    @IsBoolean()
    @IsNotEmpty()
    activo: boolean;
}

export class UpdateGradoAcademicoDto {
    @ApiPropertyOptional({ description: 'Nombre del grado académico' })
    @IsString()
    @MaxLength(100)
    @IsNotEmpty()
    nombre: string;

    @ApiPropertyOptional({ description: 'Código del grado' })
    @IsString()
    @MaxLength(20)
    @IsNotEmpty()
    codigo: string;

    @ApiPropertyOptional({ description: 'Nivel jerárquico del grado (1-7)' })
    @IsInt()
    @Min(0)
    @Max(7)
    @IsNotEmpty()
    nivel: number;

    @ApiPropertyOptional({ description: 'Si el grado está activo' })
    @IsBoolean()
    @IsNotEmpty()
    activo: boolean;
}
