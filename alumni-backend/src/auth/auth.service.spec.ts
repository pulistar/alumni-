import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { SupabaseService } from '../database/supabase.service';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let supabaseService: jest.Mocked<SupabaseService>;
  let jwtService: jest.Mocked<JwtService>;

  const mockSupabaseClient = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn(),
    insert: jest.fn().mockReturnThis(),
    auth: {
      signInWithOtp: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: SupabaseService,
          useValue: {
            getClient: jest.fn(() => mockSupabaseClient),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    supabaseService = module.get(SupabaseService) as jest.Mocked<SupabaseService>;
    jwtService = module.get(JwtService) as jest.Mocked<JwtService>;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('loginAdmin', () => {
    const loginDto = {
      email: 'admin@campusucc.edu.co',
      password: 'password123',
    };

    const mockAdmin = {
      id: '123',
      correo: 'admin@campusucc.edu.co',
      nombre: 'Admin',
      apellido: 'Test',
      password_hash: '$2b$10$hashedpassword',
      activo: true,
      rol: 'admin',
    };

    it('should successfully login with valid credentials', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: mockAdmin,
        error: null,
      });

      jest.spyOn(bcrypt, 'compare').mockResolvedValue(true as never);
      jwtService.sign.mockReturnValue('mock-jwt-token');

      const result = await service.loginAdmin(loginDto);

      expect(result).toEqual({
        accessToken: 'mock-jwt-token',
        user: {
          id: '123',
          email: 'admin@campusucc.edu.co',
          role: 'admin',
          nombre: 'Admin',
          apellido: 'Test',
        },
      });
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: '123',
        email: 'admin@campusucc.edu.co',
        role: 'admin',
      });
    });

    it('should throw UnauthorizedException when admin not found', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: null,
        error: { message: 'Not found' },
      });

      await expect(service.loginAdmin(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException when password is invalid', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: mockAdmin,
        error: null,
      });

      jest.spyOn(bcrypt, 'compare').mockResolvedValue(false as never);

      await expect(service.loginAdmin(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException when admin is inactive', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: { ...mockAdmin, activo: false },
        error: null,
      });

      await expect(service.loginAdmin(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('register', () => {
    const registerDto = {
      correo: 'newadmin@campusucc.edu.co',
      nombre: 'New',
      apellido: 'Admin',
      password: 'password123',
      confirmPassword: 'password123',
    };

    it('should successfully register a new admin', async () => {
      // Check existing email
      mockSupabaseClient.single.mockResolvedValueOnce({
        data: null,
        error: { code: 'PGRST116' },
      });

      // Insert new admin
      mockSupabaseClient.single.mockResolvedValueOnce({
        data: {
          id: '456',
          correo: registerDto.correo,
          nombre: registerDto.nombre,
          apellido: registerDto.apellido,
          rol: 'admin',
        },
        error: null,
      });

      jest.spyOn(bcrypt, 'hash').mockResolvedValue('hashed-password' as never);
      jwtService.sign.mockReturnValue('mock-jwt-token');

      const result = await service.register(registerDto);

      expect(result).toEqual({
        accessToken: 'mock-jwt-token',
        user: {
          id: '456',
          email: registerDto.correo,
          role: 'admin',
          nombre: registerDto.nombre,
          apellido: registerDto.apellido,
        },
      });
    });

    it('should throw BadRequestException when passwords do not match', async () => {
      const invalidDto = { ...registerDto, confirmPassword: 'different' };

      await expect(service.register(invalidDto)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException when email already exists', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: { id: '123' },
        error: null,
      });

      await expect(service.register(registerDto)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('sendMagicLink', () => {
    const magicLinkDto = {
      email: 'egresado@campusucc.edu.co',
    };

    it('should successfully send magic link', async () => {
      mockSupabaseClient.auth.signInWithOtp.mockResolvedValue({
        data: {},
        error: null,
      });

      await expect(
        service.sendMagicLink(magicLinkDto),
      ).resolves.toBeUndefined();

      expect(mockSupabaseClient.auth.signInWithOtp).toHaveBeenCalledWith({
        email: magicLinkDto.email,
        options: {
          emailRedirectTo: 'io.supabase.alumni://login-callback/',
        },
      });
    });

    it('should throw BadRequestException when Supabase fails', async () => {
      mockSupabaseClient.auth.signInWithOtp.mockResolvedValue({
        data: null,
        error: { message: 'Error sending email' },
      });

      await expect(service.sendMagicLink(magicLinkDto)).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
