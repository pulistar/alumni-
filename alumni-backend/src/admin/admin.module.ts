import { Module } from '@nestjs/common';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { NotificacionesModule } from '../notificaciones/notificaciones.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [NotificacionesModule, MailModule],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
