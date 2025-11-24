import { IsEmail, Matches } from 'class-validator';

/**
 * DTO for Magic Link Request
 * Validates alumni email format
 */
export class MagicLinkDto {
  @IsEmail({}, { message: 'El correo electrónico no es válido' })
  @Matches(/@campusucc\.edu\.co$/, {
    message: 'Solo se permiten correos institucionales @campusucc.edu.co',
  })
  email: string;
}
