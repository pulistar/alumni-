import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            
            _buildSection(
              '1. Información que Recopilamos',
              'La aplicación Alumni UCC recopila la siguiente información personal:\n\n'
              '• Datos de identificación: nombre completo, tipo y número de documento, lugar de expedición\n'
              '• Información de contacto: correo electrónico institucional y personal, números telefónicos\n'
              '• Información académica: ID universitario, carrera, grado académico\n'
              '• Información profesional: trayectoria laboral y académica que usted decida compartir',
            ),
            
            _buildSection(
              '2. Uso de la Información',
              'Utilizamos su información personal para:\n\n'
              '• Mantener y gestionar su perfil de egresado\n'
              '• Facilitar la comunicación entre la universidad y la comunidad de egresados\n'
              '• Proporcionar servicios exclusivos para egresados\n'
              '• Enviar notificaciones sobre eventos, oportunidades y actualizaciones relevantes\n'
              '• Generar estadísticas agregadas y anónimas para mejorar nuestros servicios',
            ),
            
            _buildSection(
              '3. Protección de Datos',
              'La Universidad Cooperativa de Colombia se compromete a proteger su información personal mediante:\n\n'
              '• Medidas de seguridad técnicas y organizativas apropiadas\n'
              '• Acceso restringido a su información solo para personal autorizado\n'
              '• Cifrado de datos sensibles durante la transmisión y almacenamiento\n'
              '• Cumplimiento de la Ley 1581 de 2012 de Protección de Datos Personales de Colombia',
            ),
            
            _buildSection(
              '4. Compartir Información',
              'No compartimos su información personal con terceros, excepto:\n\n'
              '• Cuando sea necesario para proporcionar los servicios solicitados\n'
              '• Cuando usted haya dado su consentimiento explícito\n'
              '• Cuando sea requerido por ley o autoridad competente\n'
              '• Con proveedores de servicios que nos ayudan a operar la aplicación, bajo estrictos acuerdos de confidencialidad',
            ),
            
            _buildSection(
              '5. Sus Derechos',
              'Como titular de datos personales, usted tiene derecho a:\n\n'
              '• Conocer, actualizar y rectificar sus datos personales\n'
              '• Solicitar prueba de la autorización otorgada\n'
              '• Ser informado sobre el uso dado a sus datos personales\n'
              '• Presentar quejas ante la Superintendencia de Industria y Comercio\n'
              '• Revocar la autorización y/o solicitar la supresión de sus datos cuando sea procedente\n'
              '• Acceder de forma gratuita a sus datos personales',
            ),
            
            _buildSection(
              '6. Retención de Datos',
              'Conservaremos su información personal mientras:\n\n'
              '• Mantenga su vínculo como egresado de la universidad\n'
              '• Sea necesario para cumplir con obligaciones legales\n'
              '• Existan propósitos legítimos para su conservación',
            ),
            
            _buildSection(
              '7. Cookies y Tecnologías Similares',
              'La aplicación puede utilizar tecnologías de seguimiento para mejorar la experiencia del usuario y analizar el uso de la aplicación. '
              'Puede gestionar sus preferencias en la configuración de su dispositivo.',
            ),
            
            _buildSection(
              '8. Cambios a esta Política',
              'Nos reservamos el derecho de actualizar esta Política de Privacidad. '
              'Le notificaremos sobre cambios significativos a través de la aplicación o por correo electrónico.',
            ),
            
            _buildSection(
              '9. Contacto',
              'Para ejercer sus derechos o resolver dudas sobre esta política, puede contactarnos a través de:\n\n'
              '• La opción "Ayuda" en el menú principal de la aplicación\n'
              '• Correo electrónico: ${AppConstants.supportEmail}\n'
              '• WhatsApp: ${AppConstants.supportPhone}',
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      'Al utilizar esta aplicación, usted acepta esta Política de Privacidad.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
