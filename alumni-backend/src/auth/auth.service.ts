import { Injectable, UnauthorizedException, Logger, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { SupabaseService } from '../database/supabase.service';
import { LoginAdminDto } from './dto/login-admin.dto';
import { MagicLinkDto } from './dto/magic-link.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { ITokenPayload } from './interfaces/token-payload.interface';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly jwtService: JwtService,
  ) { }

  /**
   * Authenticate Admin using Email and Password
   * @param dto LoginAdminDto
   * @returns AuthResponseDto with JWT token
   */
  async loginAdmin(dto: LoginAdminDto): Promise<AuthResponseDto> {
    const { email, password } = dto;

    // 1. Find admin in database
    const { data: admin, error } = await this.supabaseService
      .getClient()
      .from('administradores')
      .select('*')
      .eq('correo_institucional', email)
      .single();

    if (error || !admin) {
      this.logger.warn(`Failed login attempt for admin: ${email}`);
      throw new UnauthorizedException('Credenciales inválidas');
    }

    if (!admin.activo) {
      throw new UnauthorizedException('Cuenta de administrador inactiva');
    }

    // 2. Validate password
    const isPasswordValid = await bcrypt.compare(password, admin.password_hash);

    if (!isPasswordValid) {
      this.logger.warn(`Invalid password for admin: ${email}`);
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // 3. Generate JWT
    const payload: ITokenPayload = {
      sub: admin.id,
      email: admin.correo_institucional,
      role: admin.rol,
    };

    const accessToken = this.jwtService.sign(payload);

    this.logger.log(`Admin logged in successfully: ${email}`);

    return {
      accessToken,
      user: {
        id: admin.id,
        email: admin.correo_institucional,
        role: admin.rol,
        nombre: admin.nombre,
        apellido: admin.apellido,
      },
    };
  }

  /**
   * Register new administrator
   * @param registerDto RegisterDto
   * @returns AuthResponseDto with JWT token
   */
  async register(registerDto: any): Promise<AuthResponseDto> {
    const { correo_institucional, nombre, apellido, password, confirmPassword } = registerDto;

    // 1. Validate passwords match
    if (password !== confirmPassword) {
      throw new BadRequestException('Las contraseñas no coinciden');
    }

    // 2. Check if email already exists
    const { data: existingAdmin } = await this.supabaseService
      .getClient()
      .from('administradores')
      .select('id')
      .eq('correo_institucional', correo_institucional)
      .single();

    if (existingAdmin) {
      throw new BadRequestException('El correo_institucional electrónico ya está registrado');
    }

    // 3. Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // 4. Create new admin
    const { data: newAdmin, error } = await this.supabaseService
      .getClient()
      .from('administradores')
      .insert({
        correo_institucional,
        nombre,
        apellido,
        password_hash: passwordHash,
        rol: 'admin',
        activo: true,
      })
      .select()
      .single();

    if (error || !newAdmin) {
      this.logger.error(`Error creating admin: ${error?.message}`);
      throw new BadRequestException('Error al crear la cuenta');
    }

    // 5. Generate JWT
    const payload: ITokenPayload = {
      sub: newAdmin.id,
      email: newAdmin.correo_institucional,
      role: newAdmin.rol,
    };

    const accessToken = this.jwtService.sign(payload);

    this.logger.log(`New admin registered: ${correo_institucional}`);

    return {
      accessToken,
      user: {
        id: newAdmin.id,
        email: newAdmin.correo_institucional,
        role: newAdmin.rol,
        nombre: newAdmin.nombre,
        apellido: newAdmin.apellido,
      },
    };
  }

  /**
   * Send Magic Link to Alumni
   * @param dto MagicLinkDto
   */
  async sendMagicLink(dto: MagicLinkDto): Promise<void> {
    const { email } = dto;

    // Send Magic Link via Supabase
    const { error } = await this.supabaseService.getClient().auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: 'io.supabase.alumni://login-callback/',
      },
    });

    if (error) {
      this.logger.error(`Error sending magic link to ${email}: ${error.message}`);
      throw new BadRequestException('Error al enviar el enlace de acceso');
    }

    this.logger.log(`Magic link sent to: ${email}`);
  }
}

