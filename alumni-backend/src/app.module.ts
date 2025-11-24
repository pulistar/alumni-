import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';
import { DatabaseModule } from './database';
import { AuthModule } from './auth/auth.module';
import { EgresadosModule } from './egresados/egresados.module';
import { DocumentosModule } from './documentos/documentos.module';
import { AutoevaluacionModule } from './autoevaluacion/autoevaluacion.module';
import { ModulosSistemaModule } from './modulos-sistema/modulos.module';
import { AdminModule } from './admin/admin.module';
import { NotificacionesModule } from './notificaciones/notificaciones.module';
import { HealthModule } from './health/health.module';
import { MailModule } from './mail/mail.module';

/**
 * Root Application Module
 * Implements Modular Architecture pattern
 *
 * This module serves as the entry point and orchestrates all feature modules
 * following the Single Responsibility Principle
 */
@Module({
  imports: [
    // Global configuration module
    ConfigModule.forRoot({
      isGlobal: true, // Make ConfigService available globally
      envFilePath: '.env',
      cache: true, // Cache environment variables for performance
    }),

    // Rate limiting module
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 60 seconds
        limit: 100, // 100 requests per minute
      },
    ]),

    // Winston logging module
    WinstonModule.forRoot({
      transports: [
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.colorize(),
            winston.format.printf(({ timestamp, level, message, context }) => {
              return `${timestamp} [${context}] ${level}: ${message}`;
            }),
          ),
        }),
        new winston.transports.File({
          filename: 'logs/error.log',
          level: 'error',
          format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
        }),
        new winston.transports.File({
          filename: 'logs/combined.log',
          format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
        }),
      ],
    }),

    // Database module (Supabase client)
    DatabaseModule,

    // Feature modules
    AuthModule,
    EgresadosModule,
    DocumentosModule,
    AutoevaluacionModule,
    ModulosSistemaModule,
    AdminModule,
    NotificacionesModule,
    HealthModule,
    MailModule,
  ],
  controllers: [],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
