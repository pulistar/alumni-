import { Controller, Get, UseGuards } from '@nestjs/common';
import { ModulosService } from './modulos.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('modulos')
@UseGuards(SupabaseAuthGuard)
export class ModulosController {
  constructor(private readonly modulosService: ModulosService) {}

  @Get()
  async getModulos() {
    return this.modulosService.getModulosApp();
  }
}
