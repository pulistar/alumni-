import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateEgresadoDto } from './dto/create-egresado.dto';
import { UpdateEgresadoDto } from './dto/update-egresado.dto';

@Injectable()
export class EgresadosService {
  private readonly logger = new Logger(EgresadosService.name);

  constructor(private readonly supabaseService: SupabaseService) { }

  /**
   * Create or link egresado profile to Supabase User
   */
  async create(uid: string, email: string, dto: CreateEgresadoDto) {
    // 1. Check if profile already exists linked to this UID
    const { data: existingProfile } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id')
      .eq('uid', uid)
      .is('deleted_at', null)
      .single();

    if (existingProfile) {
      throw new BadRequestException('El perfil ya existe para este usuario');
    }

    // 2. Check if email is already registered (prevent duplicates)
    const { data: existingEmail } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id')
      .eq('correo_institucional', email)
      .is('deleted_at', null)
      .single();

    if (existingEmail) {
      throw new BadRequestException('El correo ya está registrado en otro perfil');
    }

    // 3. Create profile
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .insert({
        uid,
        ...dto,
        correo_institucional: email,
        // habilitado defaults to false in DB
        // Admin will enable via Excel upload or manual toggle
      })
      .select()
      .single();

    if (error) {
      this.logger.error(`Error creating profile for ${email}: ${error.message}`);
      if (error.code === '23505') {
        throw new BadRequestException('El correo ya está registrado en otro perfil');
      }
      throw new InternalServerErrorException('Error al crear el perfil');
    }

    return data;
  }

  /**
   * Find egresado profile by UID
   */
  async findOne(uid: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('*')
      .eq('uid', uid)
      .is('deleted_at', null)
      .single();

    if (error || !data) {
      if (error?.code === 'PGRST116') {
        throw new NotFoundException('Perfil no encontrado. Por favor completa tu registro.');
      }
      throw new InternalServerErrorException('Error al obtener el perfil');
    }

    return data;
  }

  /**
   * Update egresado profile
   */
  async update(uid: string, dto: UpdateEgresadoDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .update(dto)
      .eq('uid', uid)
      .is('deleted_at', null)
      .select()
      .single();

    if (error) {
      this.logger.error(`Error updating profile for ${uid}: ${error.message}`);
      throw new InternalServerErrorException('Error al actualizar el perfil');
    }

    return data;
  }

  /**
   * Soft delete egresado profile
   */
  async delete(uid: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .update({ deleted_at: new Date().toISOString() })
      .eq('uid', uid)
      .is('deleted_at', null)
      .select()
      .single();

    if (error || !data) {
      if (error?.code === 'PGRST116') {
        throw new NotFoundException('Perfil no encontrado o ya eliminado');
      }
      this.logger.error(`Error deleting profile for ${uid}: ${error?.message}`);
      throw new InternalServerErrorException('Error al eliminar el perfil');
    }

    this.logger.log(`Profile soft deleted for uid: ${uid}`);
    return { message: 'Perfil eliminado exitosamente' };
  }

  /**
   * Get all carreras
   */
  async getCarreras() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('carreras')
      .select('id, nombre, codigo, grado_academico_id')
      .eq('activa', true)
      .order('nombre', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching carreras: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener las carreras');
    }

    return data;
  }

  /**
   * Get all estados laborales
   */
  async getEstadosLaborales() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('estados_laborales')
      .select('id, nombre')
      .order('nombre', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching estados laborales: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener los estados laborales');
    }

    return data;
  }

  /**
   * Get all grados academicos
   */
  async getGradosAcademicos() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('grados_academicos')
      .select('id, nombre, nivel')
      .eq('activo', true)
      .order('nivel', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching grados academicos: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener los grados académicos');
    }

    return data;
  }

  /**
   * Get all tipos de documento
   */
  async getTiposDocumento() {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('tipos_documento')
      .select('id, codigo, nombre')
      .eq('activo', true)
      .order('nombre', { ascending: true });

    if (error) {
      this.logger.error(`Error fetching tipos de documento: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener los tipos de documento');
    }

    return data;
  }
}
