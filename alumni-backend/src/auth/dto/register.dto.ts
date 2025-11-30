import { IsEmail, IsNotEmpty, IsString, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
    @ApiProperty({ example: 'admin@example.com' })
    @IsEmail({}, { message: 'Correo electrónico inválido' })
    @IsNotEmpty({ message: 'El correo es requerido' })
    correo: string;

    @ApiProperty({ example: 'Juan' })
    @IsString()
    @IsNotEmpty({ message: 'El nombre es requerido' })
    nombre: string;

    @ApiProperty({ example: 'Pérez' })
    @IsString()
    @IsNotEmpty({ message: 'El apellido es requerido' })
    apellido: string;

    @ApiProperty({ example: 'password123' })
    @IsString()
    @MinLength(6, { message: 'La contraseña debe tener al menos 6 caracteres' })
    @IsNotEmpty({ message: 'La contraseña es requerida' })
    password: string;

    @ApiProperty({ example: 'password123' })
    @IsString()
    @IsNotEmpty({ message: 'Confirmar contraseña es requerido' })
    confirmPassword: string;
}
