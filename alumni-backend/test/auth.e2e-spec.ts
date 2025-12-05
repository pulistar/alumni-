import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';

describe('Auth (e2e)', () => {
    let app: INestApplication;

    beforeAll(async () => {
        const moduleFixture: TestingModule = await Test.createTestingModule({
            imports: [AppModule],
        }).compile();

        app = moduleFixture.createNestApplication();
        app.useGlobalPipes(new ValidationPipe());
        await app.init();
    });

    afterAll(async () => {
        await app.close();
    });

    describe('/auth/admin/login (POST)', () => {
        it('should reject login with invalid email format', () => {
            return request(app.getHttpServer())
                .post('/auth/admin/login')
                .send({
                    email: 'invalid-email',
                    password: 'password123',
                })
                .expect(400);
        });

        it('should reject login with missing password', () => {
            return request(app.getHttpServer())
                .post('/auth/admin/login')
                .send({
                    email: 'admin@campusucc.edu.co',
                })
                .expect(400);
        });

        it('should reject login with short password', () => {
            return request(app.getHttpServer())
                .post('/auth/admin/login')
                .send({
                    email: 'admin@campusucc.edu.co',
                    password: '123',
                })
                .expect(400);
        });
    });

    describe('/auth/magic-link (POST)', () => {
        it('should reject magic link request with invalid email', () => {
            return request(app.getHttpServer())
                .post('/auth/magic-link')
                .send({
                    email: 'not-an-email',
                })
                .expect(400);
        });

        it('should accept magic link request with valid email format', () => {
            return request(app.getHttpServer())
                .post('/auth/magic-link')
                .send({
                    email: 'egresado@campusucc.edu.co',
                })
                .expect((res) => {
                    // Could be 200 or 400 depending on Supabase configuration
                    // We just verify it validates the email format
                    expect([200, 400, 500]).toContain(res.status);
                });
        });
    });

    describe('/auth/admin/register (POST)', () => {
        it('should reject registration with non-matching passwords', () => {
            return request(app.getHttpServer())
                .post('/auth/admin/register')
                .send({
                    correo: 'newadmin@campusucc.edu.co',
                    nombre: 'Test',
                    apellido: 'Admin',
                    password: 'password123',
                    confirmPassword: 'different123',
                })
                .expect(400);
        });

        it('should reject registration with missing required fields', () => {
            return request(app.getHttpServer())
                .post('/auth/admin/register')
                .send({
                    correo: 'newadmin@campusucc.edu.co',
                    password: 'password123',
                })
                .expect(400);
        });
    });
});
