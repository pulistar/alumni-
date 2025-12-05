import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { LoginAdminDto } from './dto/login-admin.dto';
import { MagicLinkDto } from './dto/magic-link.dto';

describe('AuthController', () => {
    let controller: AuthController;
    let service: jest.Mocked<AuthService>;

    const mockAuthService = {
        loginAdmin: jest.fn(),
        register: jest.fn(),
        sendMagicLink: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [AuthController],
            providers: [
                {
                    provide: AuthService,
                    useValue: mockAuthService,
                },
            ],
        }).compile();

        controller = module.get<AuthController>(AuthController);
        service = module.get(AuthService) as jest.Mocked<AuthService>;
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('loginAdmin', () => {
        it('should return access token on successful login', async () => {
            const loginDto: LoginAdminDto = {
                email: 'admin@campusucc.edu.co',
                password: 'password123',
            };

            const expectedResponse = {
                accessToken: 'mock-jwt-token',
                user: {
                    id: '123',
                    email: 'admin@campusucc.edu.co',
                    role: 'admin',
                    nombre: 'Admin',
                    apellido: 'Test',
                },
            };

            mockAuthService.loginAdmin.mockResolvedValue(expectedResponse);

            const result = await controller.loginAdmin(loginDto);

            expect(result).toEqual(expectedResponse);
            expect(mockAuthService.loginAdmin).toHaveBeenCalledWith(loginDto);
        });
    });

    describe('sendMagicLink', () => {
        it('should successfully send magic link', async () => {
            const magicLinkDto: MagicLinkDto = {
                email: 'egresado@campusucc.edu.co',
            };

            mockAuthService.sendMagicLink.mockResolvedValue(undefined);

            const result = await controller.sendMagicLink(magicLinkDto);

            expect(result).toEqual({
                message: 'Enlace de acceso enviado a tu correo electrónico',
            });
            expect(mockAuthService.sendMagicLink).toHaveBeenCalledWith(magicLinkDto);
        });
    });
});
