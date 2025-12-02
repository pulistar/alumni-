import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsInt, Min } from 'class-validator';
import { ApiProperty, PartialType } from '@nestjs/swagger';

export class CreateGradoAcademicoDto {
    @ApiProperty({ description: 'Nombre del grado académico (ej: Pregrado, Maestría)' })
    @IsString()
    @IsNotEmpty()
    nombre: string;

    @ApiProperty({ description: 'Código del grado académico (ej: PREG, MAES)' })
    @IsString()
    @IsNotEmpty()
    codigo: string;

    @ApiProperty({ description: 'Nivel jerárquico (1=Auxiliar, 4=Pregrado, 6=Maestría, etc.)' })
    @IsInt()
    @Min(0)
    @IsNotEmpty()
    nivel: number;

    @ApiProperty({ description: 'Indica si el grado académico está activo', default: true })
    @IsBoolean()
    @IsOptional()
    activo?: boolean;
}

export class UpdateGradoAcademicoDto extends PartialType(CreateGradoAcademicoDto) { }
