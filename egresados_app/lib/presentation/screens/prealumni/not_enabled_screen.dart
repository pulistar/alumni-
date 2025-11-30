import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotEnabledScreen extends StatefulWidget {
  final String moduloNombre;
  
  const NotEnabledScreen({
    super.key,
    required this.moduloNombre,
  });

  @override
  State<NotEnabledScreen> createState() => _NotEnabledScreenState();
}

class _NotEnabledScreenState extends State<NotEnabledScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.moduloNombre,
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        kToolbarHeight - 
                        (AppConstants.paddingLarge * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Icono principal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Título
              Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Mensaje principal
              Text(
                'Tu cuenta aún no ha sido habilitada para acceder al módulo ${widget.moduloNombre}.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Card con información
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
                            color: AppColors.info,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Text(
                            '¿Qué significa esto?',
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
                        'El administrador del sistema debe habilitar tu cuenta para que puedas:',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingSmall),
                      
                      _buildFeatureItem('Subir documentos de grado'),
                      _buildFeatureItem('Realizar autoevaluación de competencias'),
                      _buildFeatureItem('Acceder a tu perfil completo'),
                      _buildFeatureItem('Recibir notificaciones importantes'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Card con instrucciones
              Card(
                color: AppColors.info.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.info,
                        size: 32,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      Text(
                        '¿Qué hacer mientras tanto?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingSmall),
                      
                      Text(
                        'Tu cuenta será habilitada automáticamente cuando el administrador procese la lista de egresados. Esto puede tomar algunos días.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.info,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingLarge * 2),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'Volver al Inicio',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingMedium),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Cerrar sesión
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
