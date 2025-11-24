import { IsUUID, IsOptional, IsString, IsNumber, Min, Max, ValidateIf } from 'class-validator';

export class GuardarRespuestaDto {
  @IsUUID()
  pregunta_id: string;

  @IsOptional()
  @IsString()
  @ValidateIf((o) => !o.respuesta_numerica)
  respuesta_texto?: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  @ValidateIf((o) => !o.respuesta_texto)
  respuesta_numerica?: number;
}
