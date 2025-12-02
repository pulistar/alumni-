import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Acerca de',
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
          children: [
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Logo de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.textOnPrimary,
                size: 60,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
            
            // Nombre de la app
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Versión
            Text(
              'Versión ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            // Descripción
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Sobre la Aplicación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Alumni UCC es la plataforma digital oficial que fortalece el vínculo entre la Universidad Cooperativa de Colombia '
                      'y su comunidad de egresados. A través de esta aplicación, podrás mantener actualizada tu trayectoria profesional, '
                      'acceder a servicios exclusivos, participar en la red de contactos institucional y contribuir al desarrollo '
                      'continuo de nuestra comunidad académica.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Universidad
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            AppConstants.universityName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Sede Pasto',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Términos y Condiciones
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Términos y Condiciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Normas de uso de la aplicación',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showTermsAndConditions(context);
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Licencias
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.code_outlined,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Componentes de Terceros',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Ver librerías y licencias utilizadas',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: AppConstants.appVersion,
                    applicationIcon: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.textOnPrimary,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            // Copyright
            Text(
              '© ${DateTime.now().year} Universidad Cooperativa de Colombia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Text(
              'Todos los derechos reservados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SingleChildScrollView(
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
              const SizedBox(height: 16),
              _buildTermSection(
                '1. Aceptación de los Términos',
                'Al acceder y utilizar la aplicación Alumni UCC, usted acepta estar sujeto a estos términos y condiciones de uso.',
              ),
              _buildTermSection(
                '2. Uso de la Aplicación',
                'Esta aplicación está destinada exclusivamente para egresados de la Universidad Cooperativa de Colombia. '
                'Usted se compromete a proporcionar información veraz y actualizada.',
              ),
              _buildTermSection(
                '3. Cuenta de Usuario',
                'El acceso a la aplicación se realiza mediante su correo institucional. Usted es responsable de mantener '
                'la confidencialidad de su cuenta y de todas las actividades que ocurran bajo su cuenta.',
              ),
              _buildTermSection(
                '4. Propiedad Intelectual',
                'Todo el contenido de esta aplicación, incluyendo textos, gráficos, logos e imágenes, es propiedad de la '
                'Universidad Cooperativa de Colombia y está protegido por las leyes de propiedad intelectual.',
              ),
              _buildTermSection(
                '5. Modificaciones',
                'La Universidad se reserva el derecho de modificar estos términos en cualquier momento. '
                'Las modificaciones entrarán en vigor inmediatamente después de su publicación en la aplicación.',
              ),
              _buildTermSection(
                '6. Contacto',
                'Para cualquier pregunta sobre estos términos, puede contactarnos a través de la opción "Ayuda" en el menú principal.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
