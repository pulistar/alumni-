import { Module } from '@nestjs/common';
import { AutoevaluacionService } from './autoevaluacion.service';
import { AutoevaluacionController } from './autoevaluacion.controller';
import { NotificacionesModule } from '../notificaciones/notificaciones.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [NotificacionesModule, MailModule],
  controllers: [AutoevaluacionController],
  providers: [AutoevaluacionService],
  exports: [AutoevaluacionService],
})
export class AutoevaluacionModule {}
