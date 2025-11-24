import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'data/services/auth_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart' as auth;
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/profile/complete_profile_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/widgets/loading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar configuración según entorno
  if (kDebugMode) {
    // Modo desarrollo
    AppConfig.initialize(DevelopmentEnvironment());
  } else {
    // Modo producción
    AppConfig.initialize(ProductionEnvironment());
  }
  
  // Inicializar Supabase con configuración dinámica
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(const AlumniApp());
}

class AlumniApp extends StatelessWidget {
  const AlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: AuthService())
        ..add(AuthInitialized()),
      child: MaterialApp(
        title: 'Alumni UCC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, auth.AuthState>(
      builder: (context, state) {
        // Mostrar loading mientras se inicializa
        if (state is auth.AuthInitial || state is auth.AuthLoading) {
          return const FullScreenLoading(
            message: 'Iniciando Alumni UCC...',
          );
        }
        
        // Si está autenticado con perfil completo, ir al home
        if (state is auth.AuthenticatedWithProfile) {
          return const HomeScreen();
        }
        
        // Si está autenticado pero sin perfil, ir a completar perfil
        if (state is auth.AuthenticatedWithoutProfile) {
          return const CompleteProfileScreen();
        }
        
        // Si hay error, mostrar login
        if (state is auth.AuthError) {
          return const LoginScreen();
        }
        
        // Si no está autenticado, mostrar onboarding o login
        if (state is auth.AuthUnauthenticated) {
          if (_showOnboarding) {
            return const OnboardingScreen();
          } else {
            return const LoginScreen();
          }
        }
        
        // Estado por defecto - mostrar onboarding
        return const OnboardingScreen();
      },
    );
  }
}
