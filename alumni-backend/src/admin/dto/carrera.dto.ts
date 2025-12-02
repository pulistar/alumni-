import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsUUID } from 'class-validator';
import { ApiProperty, PartialType } from '@nestjs/swagger';

export class CreateCarreraDto {
    @ApiProperty({ description: 'Nombre de la carrera' })
    @IsString()
    @IsNotEmpty()
    nombre: string;

    @ApiProperty({ description: 'Código de la carrera (ej: ING-SIS)' })
    @IsString()
    @IsNotEmpty()
    codigo: string;

    @ApiProperty({ description: 'ID del grado académico' })
    @IsUUID()
    @IsNotEmpty()
    grado_academico_id: string;

    @ApiProperty({ description: 'Indica si la carrera está activa', default: true })
    @IsBoolean()
    @IsOptional()
    activa?: boolean;
}

export class UpdateCarreraDto extends PartialType(CreateCarreraDto) { }
