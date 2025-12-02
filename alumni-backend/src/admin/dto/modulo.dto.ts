import { IsString, IsOptional, IsBoolean, IsInt, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateModuloDto {
  @ApiProperty({ description: 'Nombre del módulo' })
  @IsString()
  @IsNotEmpty()
  nombre: string;

  @ApiPropertyOptional({ description: 'Descripción del módulo' })
  @IsString()
  @IsNotEmpty()
  descripcion: string;

  @ApiProperty({ description: 'Orden del módulo' })
  @IsInt()
  @IsNotEmpty()
  orden: number;

  @ApiPropertyOptional({ description: 'Si el módulo está activo', default: true })
  @IsBoolean()
  @IsNotEmpty()
  activo: boolean;
}

export class UpdateModuloDto {
  @ApiPropertyOptional({ description: 'Nombre del módulo' })
  @IsString()
  @IsNotEmpty()
  nombre: string;

  @ApiPropertyOptional({ description: 'Descripción del módulo' })
  @IsString()
  @IsNotEmpty()
  descripcion: string;

  @ApiPropertyOptional({ description: 'Orden del módulo' })
  @IsInt()
  @IsNotEmpty()
  orden: number;

  @ApiPropertyOptional({ description: 'Si el módulo está activo' })
  @IsBoolean()
  @IsNotEmpty()
  activo: boolean;
}
