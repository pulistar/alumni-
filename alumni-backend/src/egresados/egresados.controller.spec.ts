import { Test, TestingModule } from '@nestjs/testing';
import { EgresadosController } from './egresados.controller';
import { EgresadosService } from './egresados.service';

describe('EgresadosController', () => {
    let controller: EgresadosController;
    let service: jest.Mocked<EgresadosService>;

    const mockEgresadosService = {
        create: jest.fn(),
        findOne: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        getCarreras: jest.fn(),
        getTiposDocumento: jest.fn(),
        getGradosAcademicos: jest.fn(),
        getEstadosLaborales: jest.fn(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            controllers: [EgresadosController],
            providers: [
                {
                    provide: EgresadosService,
                    useValue: mockEgresadosService,
                },
            ],
        }).compile();

        controller = module.get<EgresadosController>(EgresadosController);
        service = module.get(EgresadosService) as jest.Mocked<EgresadosService>;
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('completeProfile', () => {
        it('should create a new egresado profile', async () => {
            const createDto = {
                nombre: 'Juan',
                apellido: 'Pérez',
                celular: '3001234567',
                correo_personal: 'juan@gmail.com',
                tipo_documento_id: '1',
                documento: '1234567890',
                lugar_expedicion: 'Bogotá',
                carrera_id: '1',
                grado_academico_id: '1',
                id_universitario: 'A123',
            };

            const mockUser = {
                id: 'test-uid',
                email: 'juan.perez@campusucc.edu.co',
            };

            const expectedResult = {
                id: '1',
                ...createDto,
            };

            mockEgresadosService.create.mockResolvedValue(expectedResult);

            const result = await controller.completeProfile(mockUser as any, createDto);

            expect(result).toEqual(expectedResult);
        });
    });

    describe('getProfile', () => {
        it('should return egresado profile', async () => {
            const mockUser = {
                id: 'test-uid',
            };

            const expectedProfile = {
                id: '1',
                nombre: 'Juan',
            };

            mockEgresadosService.findOne.mockResolvedValue(expectedProfile);

            const result = await controller.getProfile(mockUser as any);

            expect(result).toEqual(expectedProfile);
        });
    });

    describe('getCarreras', () => {
        it('should return list of carreras', async () => {
            const mockCarreras = [{ id: '1', nombre: 'Ingeniería' }];

            mockEgresadosService.getCarreras.mockResolvedValue(mockCarreras);

            const result = await controller.getCarreras();

            expect(result).toEqual(mockCarreras);
        });
    });
});
