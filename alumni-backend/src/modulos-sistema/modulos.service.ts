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
   * Get all application modules ordered by 'orden'
   */
  async getModulosApp(): Promise<ModuloApp[]> {
    const { data: modulos, error } = await this.supabaseService
      .getClient()
      .from('modulos')
      .select('*')
      .order('orden', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching modules: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener módulos de la aplicación');
    }

    return modulos || [];
  }
}
