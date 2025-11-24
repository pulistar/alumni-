import { IsString, IsOptional, IsBoolean, IsInt } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateModuloDto {
  @ApiProperty({ description: 'Nombre del módulo' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ description: 'Descripción del módulo' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiProperty({ description: 'Orden del módulo' })
  @IsInt()
  orden: number;

  @ApiPropertyOptional({ description: 'Si el módulo está activo', default: true })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}

export class UpdateModuloDto {
  @ApiPropertyOptional({ description: 'Nombre del módulo' })
  @IsOptional()
  @IsString()
  nombre?: string;

  @ApiPropertyOptional({ description: 'Descripción del módulo' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ description: 'Orden del módulo' })
  @IsOptional()
  @IsInt()
  orden?: number;

  @ApiPropertyOptional({ description: 'Si el módulo está activo' })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}
