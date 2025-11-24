import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginAdminDto } from './dto/login-admin.dto';
import { MagicLinkDto } from './dto/magic-link.dto';
import { AuthResponseDto } from './dto/auth-response.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('admin/login')
  @HttpCode(HttpStatus.OK)
  async loginAdmin(@Body() dto: LoginAdminDto): Promise<AuthResponseDto> {
    return this.authService.loginAdmin(dto);
  }

  @Post('magic-link')
  @HttpCode(HttpStatus.OK)
  async sendMagicLink(@Body() dto: MagicLinkDto): Promise<{ message: string }> {
    await this.authService.sendMagicLink(dto);
    return { message: 'Enlace de acceso enviado a tu correo electrónico' };
  }
}
