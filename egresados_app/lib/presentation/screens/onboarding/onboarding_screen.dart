import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const OnboardingScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animación de slide up
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    // Si hay un callback, usarlo en lugar de navegar
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    
    // Si no hay callback, navegar normalmente
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              // Espaciador superior
              const Spacer(flex: 2),
              
              // Logo y título principal
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Logo Alumni (placeholder - puedes reemplazar con tu logo)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Título principal
                      Text(
                        'Alumni',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingSmall),
                      
                      // Subtítulo
                      Text(
                        'UCC',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Descripción
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  child: Text(
                    'Conecta con tu universidad y mantente al día con tu proceso de grado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textOnPrimary.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Botones de acción
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Botón principal - Continuar
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textOnPrimary,
                          foregroundColor: AppColors.primary,
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    // Indicador de deslizar
                    GestureDetector(
                      onTap: _navigateToLogin,
                      onHorizontalDragEnd: (details) {
                        // Si desliza hacia la izquierda
                        if (details.primaryVelocity! < 0) {
                          _navigateToLogin();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Desliza para continuar',
                              style: TextStyle(
                                color: AppColors.textOnPrimary.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textOnPrimary.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  AppConstants.universityName,
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
