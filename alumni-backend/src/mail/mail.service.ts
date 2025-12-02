import { Injectable, Logger } from '@nestjs/common';
import { MailerService } from '@nestjs-modules/mailer';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);

  constructor(
    private mailerService: MailerService,
    private configService: ConfigService,
  ) { }

  async sendCuentaHabilitada(email: string, nombre: string, apellido: string) {
    const appUrl = this.configService.get('APP_URL') || 'http://localhost:4200';

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: '¡Tu cuenta ha sido habilitada! - Sistema de Egresados UCC',
        html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <div style="background: #003366; color: white; padding: 20px; text-align: center;">
                            <h1>¡Bienvenido al Sistema de Egresados!</h1>
                        </div>
                        <div style="padding: 20px; background: #f5f5f5;">
                            <p>Hola <strong>${nombre} ${apellido}</strong>,</p>
                            <p>Tu cuenta ha sido habilitada exitosamente en el Sistema de Egresados de la Universidad Cooperativa de Colombia.</p>
                            <p>Ya puedes acceder al sistema y subir tus documentos de grado.</p>
                            <p style="text-align: center; margin: 30px 0;">
                                <a href="${appUrl}/login" style="background: #003366; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                                    Acceder al Sistema
                                </a>
                            </p>
                            <p>Saludos,<br><strong>Universidad Cooperativa de Colombia</strong></p>
                        </div>
                    </div>
                `,
      });

      this.logger.log(`Email sent to ${email}: Cuenta habilitada`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${email}: ${error.message}`);
      // No throw error, email is not critical
    }
  }

  async sendPdfGenerado(email: string, nombre: string) {
    const appUrl = this.configService.get('APP_URL') || 'http://localhost:4200';

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: '¡Tu PDF unificado está listo! - Sistema de Egresados UCC',
        html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <div style="background: #003366; color: white; padding: 20px; text-align: center;">
                            <h1>PDF Unificado Generado</h1>
                        </div>
                        <div style="padding: 20px; background: #f5f5f5;">
                            <p>Hola <strong>${nombre}</strong>,</p>
                            <p>Tu PDF unificado ha sido generado exitosamente.</p>
                            <p>Tus documentos han sido procesados y combinados en un solo archivo.</p>
                            <p style="text-align: center; margin: 30px 0;">
                                <a href="${appUrl}/documentos" style="background: #003366; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                                    Ver Documentos
                                </a>
                            </p>
                            <p>Saludos,<br><strong>Universidad Cooperativa de Colombia</strong></p>
                        </div>
                    </div>
                `,
      });

      this.logger.log(`Email sent to ${email}: PDF generado`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${email}: ${error.message}`);
    }
  }

  async sendAutoevaluacionCompletada(email: string, nombre: string) {
    try {
      await this.mailerService.sendMail({
        to: email,
        subject: '¡Autoevaluación completada! - Sistema de Egresados UCC',
        html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <div style="background: #003366; color: white; padding: 20px; text-align: center;">
                            <h1>¡Felicidades!</h1>
                        </div>
                        <div style="padding: 20px; background: #f5f5f5;">
                            <p>Hola <strong>${nombre}</strong>,</p>
                            <p>¡Felicidades! Has completado tu autoevaluación de competencias.</p>
                            <p>Gracias por tu participación en el proceso de seguimiento a egresados.</p>
                            <p>Tu información es muy valiosa para mejorar nuestros programas académicos.</p>
                            <p>Saludos,<br><strong>Universidad Cooperativa de Colombia</strong></p>
                        </div>
                    </div>
                `,
      });

      this.logger.log(`Email sent to ${email}: Autoevaluación completada`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${email}: ${error.message}`);
    }
  }
  async sendInvitacion(email: string, nombre: string) {
    const appUrl = this.configService.get('APP_URL') || 'http://localhost:4200';
    const registerUrl = `${appUrl}/registro`;

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: '¡Invitación a unirte al Sistema de Egresados UCC!',
        html: `
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <div style="background: #003366; color: white; padding: 20px; text-align: center;">
                            <h1>¡Únete a nuestra Red de Egresados!</h1>
                        </div>
                        <div style="padding: 20px; background: #f5f5f5;">
                            <p>Hola <strong>${nombre}</strong>,</p>
                            <p>La Universidad Cooperativa de Colombia te invita a formar parte de su nueva plataforma de egresados.</p>
                            <p>Actualiza tus datos, conecta con compañeros y accede a beneficios exclusivos.</p>
                            <p style="text-align: center; margin: 30px 0;">
                                <a href="${registerUrl}" style="background: #003366; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                                    Registrarme Ahora
                                </a>
                            </p>
                            <p>Si ya tienes cuenta, puedes iniciar sesión <a href="${appUrl}/login">aquí</a>.</p>
                            <p>Saludos,<br><strong>Universidad Cooperativa de Colombia</strong></p>
                        </div>
                    </div>
                `,
      });

      this.logger.log(`Email de invitación enviado a ${email}`);
    } catch (error) {
      this.logger.error(`Error enviando invitación a ${email}: ${error.message}`);
    }
  }
}
