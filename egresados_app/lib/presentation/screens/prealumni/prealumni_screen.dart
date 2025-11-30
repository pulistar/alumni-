import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'not_enabled_screen.dart';
import '../documentos/upload_documentos_screen.dart';
import '../autoevaluacion/autoevaluacion_screen.dart';
import '../../../data/models/user_model.dart';

class PreAlumniScreen extends StatefulWidget {
  final String moduloNombre;
  
  const PreAlumniScreen({
    super.key,
    required this.moduloNombre,
  });

  @override
  State<PreAlumniScreen> createState() => _PreAlumniScreenState();
}

class _PreAlumniScreenState extends State<PreAlumniScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthenticatedWithProfile) {
          // Verificar si el egresado está habilitado
          if (!state.egresado.habilitado) {
            return NotEnabledScreen(moduloNombre: widget.moduloNombre);
          }
          
          return _buildEnabledPreAlumniScreen(state);
        }
        
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildEnabledPreAlumniScreen(AuthenticatedWithProfile state) {
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
      body: _buildPreAlumniContent(state),
    );
  }

  Widget _buildPreAlumniContent(AuthenticatedWithProfile state) {
    final egresado = state.egresado;
    
    return SafeArea(
      child: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  // Estado del perfil
                  _buildProfileStatusCard(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Acciones rápidas (sin editar perfil y notificaciones)
                  _buildQuickActions(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Progreso general
                  _buildProgressCard(egresado),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatusCard(egresado) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Estado del Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Perfil completado',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Text(
              'Tu información básica está registrada correctamente.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(EgresadoModel egresado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppConstants.paddingMedium,
          crossAxisSpacing: AppConstants.paddingMedium,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              icon: Icons.upload_file_outlined,
              title: 'Subir\nDocumentos',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UploadDocumentosScreen(),
                  ),
                );
              },
            ),
            
            _buildActionCard(
              icon: Icons.quiz_outlined,
              title: 'Auto-\nevaluación',
              color: egresado.autoevaluacionHabilitada 
                  ? AppColors.secondary 
                  : AppColors.textSecondary,
              onTap: () {
                if (egresado.autoevaluacionHabilitada) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AutoevaluacionScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Debes subir todos los documentos para habilitar la autoevaluación',
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(egresado) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildProgressItem(
              title: 'Perfil completado',
              isCompleted: true,
            ),
            
            _buildProgressItem(
              title: 'Documentos subidos',
              isCompleted: egresado.autoevaluacionHabilitada,
            ),
            
            _buildProgressItem(
              title: 'Autoevaluación completada',
              isCompleted: egresado.autoevaluacionCompletada,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }



  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente disponible'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
