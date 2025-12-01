import { IsString, IsBoolean, IsOptional, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCarreraDto {
    @ApiProperty({ description: 'Nombre de la carrera', example: 'Ingeniería de Sistemas' })
    @IsString()
    @MaxLength(255)
    nombre: string;

    @ApiPropertyOptional({ description: 'Código de la carrera', example: 'ING-SIS' })
    @IsString()
    @IsOptional()
    @MaxLength(50)
    codigo?: string;

    @ApiPropertyOptional({ description: 'Si la carrera está activa', example: true, default: true })
    @IsBoolean()
    @IsOptional()
    activa?: boolean;
}

export class UpdateCarreraDto {
    @ApiPropertyOptional({ description: 'Nombre de la carrera' })
    @IsString()
    @IsOptional()
    @MaxLength(255)
    nombre?: string;

    @ApiPropertyOptional({ description: 'Código de la carrera' })
    @IsString()
    @IsOptional()
    @MaxLength(50)
    codigo?: string;

    @ApiPropertyOptional({ description: 'Si la carrera está activa' })
    @IsBoolean()
    @IsOptional()
    activa?: boolean;
}
