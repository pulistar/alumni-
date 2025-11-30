import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';

export interface ModuloApp {
  id: string;
  nombre: string;
  descripcion: string;
  icono: string;
  orden: number;
  activo: boolean;
  ruta?: string;
}

@Injectable()
export class ModulosService {
  private readonly logger = new Logger(ModulosService.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Get all active application modules ordered by 'orden'
   * Only returns modules where activo = true for mobile app
   */
  async getModulosApp(): Promise<ModuloApp[]> {
    const { data: modulos, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .select('*')
      .eq('activo', true)  // 🔥 Solo módulos activos
      .order('orden', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching active modules: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener módulos activos de la aplicación');
    }

    this.logger.log(`Found ${modulos?.length || 0} active modules`);
    return modulos || [];
  }

  /**
   * Get ALL modules (active and inactive) for admin panel
   */
  async getAllModulos(): Promise<ModuloApp[]> {
    const { data: modulos, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .select('*')
      .order('orden', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching all modules: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener todos los módulos');
    }

    this.logger.log(`Found ${modulos?.length || 0} total modules`);
    return modulos || [];
  }
}
