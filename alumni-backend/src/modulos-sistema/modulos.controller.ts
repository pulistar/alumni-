import { Controller, Get, UseGuards } from '@nestjs/common';
import { ModulosService } from './modulos.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@Controller('modulos')
export class ModulosController {
  constructor(private readonly modulosService: ModulosService) {}

  @Get()
  @UseGuards(SupabaseAuthGuard)
  async getModulosActivos() {
    // Para app móvil - solo módulos activos
    return this.modulosService.getModulosApp();
  }

  @Get('admin/all')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  async getAllModulos() {
    // Para panel admin - todos los módulos
    return this.modulosService.getAllModulos();
  }
}
