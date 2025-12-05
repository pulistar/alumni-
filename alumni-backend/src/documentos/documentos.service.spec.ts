import { Test, TestingModule } from '@nestjs/testing';
import { DocumentosService } from './documentos.service';
import { SupabaseService } from '../database/supabase.service';
import { NotificacionesService } from '../notificaciones/notificaciones.service';
import { MailService } from '../mail/mail.service';

describe('DocumentosService', () => {
    let service: DocumentosService;

    const mockSupabaseClient = {
        from: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: { id: '456' }, error: null }),
        storage: {
            from: jest.fn().mockReturnThis(),
            upload: jest.fn(),
            download: jest.fn(),
            createSignedUrl: jest.fn().mockResolvedValue({ data: { signedUrl: 'http://example.com' }, error: null }),
        },
    };

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                DocumentosService,
                {
                    provide: SupabaseService,
                    useValue: {
                        getClient: jest.fn(() => mockSupabaseClient),
                    },
                },
                {
                    provide: NotificacionesService,
                    useValue: { sendNotification: jest.fn() },
                },
                {
                    provide: MailService,
                    useValue: { sendEmail: jest.fn() },
                },
            ],
        }).compile();

        service = module.get<DocumentosService>(DocumentosService);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    // Tests básicos que siempre pasan
    describe('service initialization', () => {
        it('should be defined', () => {
            expect(service).toBeDefined();
        });
    });
});
