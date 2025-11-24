import { Controller, Get, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { AutoevaluacionService } from './autoevaluacion.service';
import { GuardarRespuestaDto } from './dto/respuesta.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ICurrentUser } from '../auth/interfaces/current-user.interface';

@Controller('autoevaluacion')
@UseGuards(SupabaseAuthGuard)
export class AutoevaluacionController {
  constructor(private readonly autoevaluacionService: AutoevaluacionService) {}

  @Get('preguntas')
  async getPreguntas(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.autoevaluacionService.getEgresadoIdByUid(user.id);
    return this.autoevaluacionService.getPreguntas(egresadoId);
  }

  @Post('respuesta')
  @HttpCode(HttpStatus.CREATED)
  async guardarRespuesta(@CurrentUser() user: ICurrentUser, @Body() dto: GuardarRespuestaDto) {
    const egresadoId = await this.autoevaluacionService.getEgresadoIdByUid(user.id);
    return this.autoevaluacionService.guardarRespuesta(egresadoId, dto);
  }

  @Get('progreso')
  async getProgreso(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.autoevaluacionService.getEgresadoIdByUid(user.id);
    return this.autoevaluacionService.getProgreso(egresadoId);
  }

  @Post('completar')
  @HttpCode(HttpStatus.OK)
  async marcarComoCompletada(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.autoevaluacionService.getEgresadoIdByUid(user.id);
    return this.autoevaluacionService.marcarComoCompletada(egresadoId);
  }
}
