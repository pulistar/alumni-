import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Delete,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { EgresadosService } from './egresados.service';
import { CreateEgresadoDto } from './dto/create-egresado.dto';
import { UpdateEgresadoDto } from './dto/update-egresado.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ICurrentUser } from '../auth/interfaces/current-user.interface';

@Controller('egresados')
@UseGuards(SupabaseAuthGuard)
export class EgresadosController {
  constructor(private readonly egresadosService: EgresadosService) {}

  @Post('completar-perfil')
  @HttpCode(HttpStatus.CREATED)
  async completeProfile(@CurrentUser() user: ICurrentUser, @Body() dto: CreateEgresadoDto) {
    return this.egresadosService.create(user.id, user.email, dto);
  }

  @Get('me')
  async getProfile(@CurrentUser() user: ICurrentUser) {
    return this.egresadosService.findOne(user.id);
  }

  @Patch('me')
  async updateProfile(@CurrentUser() user: ICurrentUser, @Body() dto: UpdateEgresadoDto) {
    return this.egresadosService.update(user.id, dto);
  }

  @Delete('me')
  @HttpCode(HttpStatus.OK)
  async deleteProfile(@CurrentUser() user: ICurrentUser) {
    return this.egresadosService.delete(user.id);
  }

  @Get('carreras')
  @HttpCode(HttpStatus.OK)
  async getCarreras() {
    return this.egresadosService.getCarreras();
  }

  @Get('estados-laborales')
  @HttpCode(HttpStatus.OK)
  async getEstadosLaborales() {
    return this.egresadosService.getEstadosLaborales();
  }
}
