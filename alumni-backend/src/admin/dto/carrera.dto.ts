import { IsString, IsBoolean, IsOptional, MaxLength, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCarreraDto {
    @ApiProperty({ description: 'Nombre de la carrera', example: 'Ingeniería de Sistemas' })
    @IsString()
    @MaxLength(255)
    @IsNotEmpty()
    nombre: string;

    @ApiPropertyOptional({ description: 'Código de la carrera', example: 'ING-SIS' })
    @IsString()
    @MaxLength(50)
    @IsNotEmpty()
    codigo: string;

    @ApiPropertyOptional({ description: 'Si la carrera está activa', example: true, default: true })
    @IsBoolean()
    @IsNotEmpty()
    activa: boolean;
}

export class UpdateCarreraDto {
    @ApiPropertyOptional({ description: 'Nombre de la carrera' })
    @IsString()
    @MaxLength(255)
    @IsNotEmpty()
    nombre: string;

    @ApiPropertyOptional({ description: 'Código de la carrera' })
    @IsString()
    @MaxLength(50)
    @IsNotEmpty()
    codigo: string;

    @ApiPropertyOptional({ description: 'Si la carrera está activa' })
    @IsBoolean()
    @IsNotEmpty()
    activa: boolean;
}
