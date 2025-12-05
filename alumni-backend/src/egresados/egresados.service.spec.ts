import { Test, TestingModule } from '@nestjs/testing';
import { EgresadosService } from './egresados.service';
import { SupabaseService } from '../database/supabase.service';
import {
    BadRequestException,
    NotFoundException,
    InternalServerErrorException,
} from '@nestjs/common';

describe('EgresadosService', () => {
    let service: EgresadosService;

    const mockSupabaseClient = {
        from: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        is: jest.fn().mockReturnThis(),
        single: jest.fn(),
        insert: jest.fn().mockReturnThis(),
        update: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                EgresadosService,
                {
                    provide: SupabaseService,
                    useValue: {
                        getClient: jest.fn(() => mockSupabaseClient),
                    },
                },
            ],
        }).compile();

        service = module.get<EgresadosService>(EgresadosService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe('findOne', () => {
        it('should return egresado profile', async () => {
            const uid = 'test-uid';
            const mockEgresado = {
                id: '1',
                uid,
                nombre: 'Juan',
            };

            mockSupabaseClient.single.mockResolvedValue({
                data: mockEgresado,
                error: null,
            });

            const result = await service.findOne(uid);

            expect(result).toEqual(mockEgresado);
        });

        it('should throw NotFoundException when not found', async () => {
            mockSupabaseClient.single.mockResolvedValue({
                data: null,
                error: { code: 'PGRST116' },
            });

            await expect(service.findOne('uid')).rejects.toThrow(NotFoundException);
        });
    });

    describe('getCarreras', () => {
        it('should return list of carreras', async () => {
            const mockCarreras = [{ id: '1', nombre: 'Ingeniería' }];

            mockSupabaseClient.order.mockResolvedValue({
                data: mockCarreras,
                error: null,
            });

            const result = await service.getCarreras();

            expect(result).toEqual(mockCarreras);
        });
    });

    describe('getTiposDocumento', () => {
        it('should return tipos de documento', async () => {
            const mockTipos = [{ id: '1', codigo: 'CC' }];

            mockSupabaseClient.order.mockResolvedValue({
                data: mockTipos,
                error: null,
            });

            const result = await service.getTiposDocumento();

            expect(result).toEqual(mockTipos);
        });
    });
});
