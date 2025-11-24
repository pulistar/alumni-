import { IsEmail, IsString, MinLength, Matches } from 'class-validator';

/**
 * DTO for Admin Login
 * Validates email format and password length
 */
export class LoginAdminDto {
  @IsEmail({}, { message: 'El correo electrónico no es válido' })
  @Matches(/@campusucc\.edu\.co$/, {
    message: 'Solo se permiten correos institucionales @campusucc.edu.co',
  })
  email: string;

  @IsString()
  @MinLength(6, { message: 'La contraseña debe tener al menos 6 caracteres' })
  password: string;
}
