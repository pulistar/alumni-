import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/carreras_service.dart';
import '../../../data/services/estados_laborales_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final CarrerasService _carrerasService = CarrerasService();
  final EstadosLaboralesService _estadosLaboralesService = EstadosLaboralesService();
  String? _carreraNombre;
  String? _estadoLaboralNombre;

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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _loadCarreraNombre();
    _loadEstadoLaboralNombre();
  }

  void _loadCarreraNombre() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedWithProfile && authState.egresado.carreraId != null) {
      try {
        final nombre = await _carrerasService.getCarreraNombre(authState.egresado.carreraId!);
        if (mounted) {
          setState(() {
            _carreraNombre = nombre;
          });
        }
      } catch (e) {
        print('❌ Error cargando nombre de carrera: $e');
      }
    }
  }

  void _loadEstadoLaboralNombre() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedWithProfile && authState.egresado.estadoLaboralId != null) {
      try {
        final nombre = await _estadosLaboralesService.getEstadoLaboralNombre(authState.egresado.estadoLaboralId!);
        if (mounted) {
          setState(() {
            _estadoLaboralNombre = nombre;
          });
        }
      } catch (e) {
        print('❌ Error cargando nombre de estado laboral: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthenticatedWithProfile) {
            return _buildProfileContent(state);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(AuthenticatedWithProfile state) {
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
                  // Header del perfil
                  _buildProfileHeader(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Información personal
                  _buildPersonalInfoCard(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Información académica
                  _buildAcademicInfoCard(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Información laboral
                  _buildWorkInfoCard(egresado),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Estado del perfil
                  _buildProfileStatusCard(egresado),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(egresado) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Nombre completo
            Text(
              '${egresado.nombre} ${egresado.apellido}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Email
            Text(
              egresado.correo,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textOnPrimary.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Estado de habilitación
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: egresado.habilitado 
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: egresado.habilitado 
                    ? AppColors.success
                    : AppColors.warning,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    egresado.habilitado 
                      ? Icons.check_circle
                      : Icons.schedule,
                    size: 16,
                    color: egresado.habilitado 
                      ? AppColors.success
                      : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    egresado.habilitado 
                      ? 'Cuenta Habilitada'
                      : 'Pendiente de Habilitación',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: egresado.habilitado 
                        ? AppColors.success
                        : AppColors.warning,
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

  Widget _buildPersonalInfoCard(egresado) {
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
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildInfoRow('Nombre', egresado.nombre),
            _buildInfoRow('Apellido', egresado.apellido),
            _buildInfoRow('Correo', egresado.correo),
            if (egresado.telefono != null)
              _buildInfoRow('Teléfono', egresado.telefono!),
            if (egresado.ciudad != null)
              _buildInfoRow('Ciudad', egresado.ciudad!),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoCard(egresado) {
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
                  Icons.school_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información Académica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (egresado.carreraId != null)
              _buildInfoRow(
                'Carrera', 
                _carreraNombre ?? 'Cargando...'
              )
            else
              _buildInfoRow('Carrera', 'No especificada'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkInfoCard(egresado) {
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
                  Icons.work_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información Laboral',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (egresado.estadoLaboralId != null)
              _buildInfoRow(
                'Estado Laboral', 
                _estadoLaboralNombre ?? 'Cargando...'
              )
            else
              _buildInfoRow('Estado Laboral', 'No especificado'),
            if (egresado.empresaActual != null)
              _buildInfoRow('Empresa Actual', egresado.empresaActual!),
            if (egresado.cargoActual != null)
              _buildInfoRow('Cargo Actual', egresado.cargoActual!),
          ],
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
                  Icons.analytics_outlined,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Estado del Proceso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildStatusItem(
              'Perfil Completado',
              true,
              'Tu información básica está registrada',
            ),
            
            _buildStatusItem(
              'Proceso de Grado',
              egresado.procesoGradoCompleto,
              egresado.procesoGradoCompleto 
                ? 'Proceso completado exitosamente'
                : 'Pendiente de completar documentos',
            ),
            
            _buildStatusItem(
              'Autoevaluación Habilitada',
              egresado.autoevaluacionHabilitada,
              egresado.autoevaluacionHabilitada 
                ? 'Puedes realizar la autoevaluación'
                : 'Completa el proceso de grado primero',
            ),
            
            _buildStatusItem(
              'Autoevaluación Completada',
              egresado.autoevaluacionCompletada,
              egresado.autoevaluacionCompletada 
                ? 'Autoevaluación finalizada'
                : 'Pendiente de realizar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isCompleted, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isCompleted 
          ? AppColors.success.withOpacity(0.1)
          : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
            ? AppColors.success.withOpacity(0.3)
            : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: isCompleted ? AppColors.success : AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
