import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/modulo.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/modulos/modulos_bloc.dart';
import '../../blocs/modulos/modulos_event.dart';
import '../../blocs/modulos/modulos_state.dart';
import '../prealumni/prealumni_screen.dart';
import '../prealumni/not_enabled_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/help_screen.dart';
import '../../widgets/support_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _refreshTimer;

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
    
    // Cargar módulos al inicializar
    context.read<ModulosBloc>().add(ModulosLoadRequested());
    
    // Configurar refresh automático cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<ModulosBloc>().add(ModulosRefreshRequested());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthenticatedWithProfile) {
            return _buildModulosHome(authState);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildModulosHome(AuthenticatedWithProfile authState) {
    final egresado = authState.egresado;
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Refrescar tanto módulos como perfil
          context.read<ModulosBloc>().add(ModulosRefreshRequested());
          context.read<AuthBloc>().add(AuthProfileRefreshRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header con información del usuario
              _buildHeader(egresado.nombreCompleto),
              
              // Módulos del sistema
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: BlocBuilder<ModulosBloc, ModulosState>(
                      builder: (context, modulosState) {
                        if (modulosState is ModulosLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (modulosState is ModulosError) {
                          return _buildErrorCard(modulosState.message);
                        }
                        
                        if (modulosState is ModulosLoaded) {
                          return _buildModulosGrid(modulosState.modulosActivos);
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String nombreCompleto) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo y título
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Text(
                        'Alumni UCC',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Botón de refrescar perfil
                      IconButton(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔄 Actualizando estado de la cuenta...'),
                              backgroundColor: AppColors.info,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          context.read<AuthBloc>().add(AuthProfileRefreshRequested());
                          
                          // Esperar un poco y mostrar resultado
                          await Future.delayed(Duration(seconds: 1));
                          if (mounted) {
                            final currentState = context.read<AuthBloc>().state;
                            if (currentState is AuthenticatedWithProfile) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    currentState.egresado.habilitado 
                                      ? '✅ ¡Cuenta habilitada! Ya puedes acceder a PreAlumni'
                                      : '⏳ Cuenta aún no habilitada por el administrador'
                                  ),
                                  backgroundColor: currentState.egresado.habilitado 
                                    ? AppColors.success 
                                    : AppColors.warning,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.textOnPrimary,
                          size: 24,
                        ),
                      ),
                      
                      // Botón de perfil/configuración
                      IconButton(
                        onPressed: () {
                          _showProfileMenu(context);
                        },
                        icon: Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.textOnPrimary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Saludo personalizado
              Text(
                '¡Hola, ${nombreCompleto.split(' ').first}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnPrimary,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              Text(
                'Selecciona un módulo para comenzar',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textOnPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModulosGrid(List<Modulo> modulos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos Disponibles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        Text(
          'Explora las diferentes funcionalidades del sistema Alumni UCC',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppConstants.paddingMedium,
            crossAxisSpacing: AppConstants.paddingMedium,
            childAspectRatio: 0.85,
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            final modulo = modulos[index];
            return _buildModuloCard(modulo);
          },
        ),
      ],
    );
  }

  Widget _buildModuloCard(Modulo modulo) {
    // Verificar si es el módulo PreAlumni (por icono 'school' y orden 1)
    bool isPreAlumni = modulo.icono.toLowerCase() == 'school' && modulo.orden == 1;
    bool isEnabled = true;
    
    final authState = context.read<AuthBloc>().state;
    if (isPreAlumni && authState is AuthenticatedWithProfile) {
      isEnabled = authState.egresado.habilitado;
    }
    
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _onModuloTapped(modulo),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                color: (!isEnabled) ? Colors.grey.withOpacity(0.1) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono del módulo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getModuloColor(modulo.nombre).withOpacity(isEnabled ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _getModuloIcon(modulo.icono),
                      color: _getModuloColor(modulo.nombre).withOpacity(isEnabled ? 1.0 : 0.5),
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingSmall),
                  
                  // Nombre del módulo
                  Flexible(
                    child: Text(
                      modulo.nombre,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingSmall),
                  
                  // Descripción del módulo
                  Flexible(
                    child: Text(
                      modulo.descripcion,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Badge de estado para PreAlumni
          if (isPreAlumni && !isEnabled)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Bloqueado',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Error al cargar módulos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: () {
                context.read<ModulosBloc>().add(ModulosLoadRequested());
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuloIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'school':
        return Icons.school;
      case 'people':
        return Icons.people;
      case 'work':
        return Icons.work;
      case 'event':
        return Icons.event;
      case 'support':
        return Icons.support_agent;
      case 'book':
        return Icons.book;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'forum':
        return Icons.forum;
      default:
        return Icons.apps;
    }
  }

  Color _getModuloColor(String moduloNombre) {
    // Mantener colores por nombre para compatibilidad, pero agregar lógica por icono
    switch (moduloNombre.toLowerCase()) {
      case 'prealumni':
      case 'red de contacto': // Nuevo nombre del módulo PreAlumni
        return AppColors.primary;
      case 'red de egresados':
      case 'red de conocimientos':
        return AppColors.secondary;
      case 'bolsa de empleo':
        return AppColors.success;
      case 'eventos alumni':
      case 'red bienestar':
        return AppColors.warning;
      case 'mentoría':
        return AppColors.info;
      case 'educación continua':
        return Colors.purple;
      case 'emprendimiento':
        return Colors.orange;
      case 'beneficios':
        return Colors.pink;
      case 'comunidad':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  void _onModuloTapped(Modulo modulo) {
    print('📱 Módulo seleccionado: ${modulo.nombre}');
    
    // Verificar si es el módulo PreAlumni (por icono 'school' y orden 1)
    bool isPreAlumni = modulo.icono.toLowerCase() == 'school' && modulo.orden == 1;
    
    if (isPreAlumni) {
      // Verificar si el egresado está habilitado antes de navegar
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedWithProfile) {
        if (authState.egresado.habilitado) {
          // Navegar a PreAlumniScreen con el nombre del módulo
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreAlumniScreen(moduloNombre: modulo.nombre),
            ),
          );
        } else {
          // Mostrar pantalla de no habilitado con el nombre del módulo
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NotEnabledScreen(moduloNombre: modulo.nombre),
            ),
          );
        }
      }
    } else {
      // Mostrar "Próximamente" para otros módulos
      _showComingSoon(modulo.nombre);
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Ver Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Ayuda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            child: Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
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
