import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'data/services/auth_service.dart';
import 'data/services/modulos_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart' as auth;
import 'presentation/blocs/modulos/modulos_bloc.dart';
import 'data/services/autoevaluacion_service.dart';
import 'presentation/blocs/autoevaluacion/autoevaluacion_bloc.dart';
import 'package:dio/dio.dart';
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
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const AlumniApp());
}

class AlumniApp extends StatefulWidget {
  const AlumniApp({super.key});

  @override
  State<AlumniApp> createState() => _AlumniAppState();
}

class _AlumniAppState extends State<AlumniApp> {
  late AuthBloc _authBloc;
  late AuthService _authService;
  late ModulosService _modulosService;
  late ModulosBloc _modulosBloc;
  late AutoevaluacionService _autoevaluacionService;
  late AutoevaluacionBloc _autoevaluacionBloc;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _authBloc = AuthBloc(authService: _authService);
    _modulosService = ModulosService();
    _modulosBloc = ModulosBloc(modulosService: _modulosService);
    _autoevaluacionService = AutoevaluacionService(Dio(), Supabase.instance.client);
    _autoevaluacionBloc = AutoevaluacionBloc(_autoevaluacionService);
    _appLinks = AppLinks();
    _setupDeepLinkHandling();
  }

  void _setupDeepLinkHandling() {
    // Escuchar deep links entrantes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('🔥 Auth event: ${data.event}');
      print('🔥 Session: ${data.session?.user?.email}');
      
      if (data.event == AuthChangeEvent.signedIn || 
          data.event == AuthChangeEvent.tokenRefreshed) {
        print('🔥 Deep link auth successful: ${data.session?.user?.email}');
        _authBloc.add(AuthInitialized());
      }
    });

    // Escuchar cambios de autenticación de Supabase directamente
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      print('🔐 Supabase Auth Event: $event');
      
      if (event == AuthChangeEvent.signedOut) {
        print('🔐 Usuario cerró sesión, forzando navegación al login');
        // Forzar navegación al login después del logout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print('🔐 Navegando a LoginScreen por signOut');
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    });

    // Escuchar deep links manualmente
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('🔗 Deep link received: $uri');
      _handleDeepLink(uri);
    });

    // Verificar deep link inicial
    _processInitialDeepLink();
  }

  void _processInitialDeepLink() async {
    try {
      print('🔗 Processing initial deep link...');
      
      // Verificar deep link inicial
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 Initial deep link found: $initialUri');
        _handleDeepLink(initialUri);
      }
      
      // Esperar un momento para que la app se inicialice
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verificar si Supabase ya procesó algún deep link
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        print('🔗 Session already exists: ${session.user.email}');
        _authBloc.add(AuthInitialized());
      } else {
        print('🔗 No session found, waiting for deep link...');
      }
    } catch (e) {
      print('🔗 Error processing initial deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) async {
    try {
      print('🔗 Handling deep link: $uri');
      
      // Verificar si es un magic link de Supabase
      if (uri.scheme == 'io.supabase.alumni' && uri.host == 'login-callback') {
        print('🔗 Magic link detected, extracting tokens...');
        
        // Extraer tokens del fragment
        final fragment = uri.fragment;
        final params = Uri.splitQueryString(fragment);
        
        final accessToken = params['access_token'];
        final refreshToken = params['refresh_token'];
        
        if (accessToken != null && refreshToken != null) {
          print('🔗 Tokens found, setting session...');
          print('🔗 Access token length: ${accessToken.length}');
          print('🔗 Refresh token: $refreshToken');
          
          // setSession solo acepta refreshToken según la documentación de Supabase
          final response = await Supabase.instance.client.auth.setSession(refreshToken);
          
          if (response.session != null) {
            print('🔗 Session set successfully! User: ${response.session!.user.email}');
          } else {
            print('🔗 Failed to set session');
          }
        } else {
          print('🔗 No tokens found in URL');
          print('🔗 Access token: ${accessToken?.substring(0, 50)}...');
          print('🔗 Refresh token: $refreshToken');
        }
      }
    } catch (e) {
      print('🔗 Error handling deep link: $e');
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _modulosBloc.close();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: _authService),
        Provider<ModulosService>.value(value: _modulosService),
        Provider<AutoevaluacionService>.value(value: _autoevaluacionService),
        BlocProvider<AuthBloc>.value(value: _authBloc..add(AuthInitialized())),
        BlocProvider<ModulosBloc>.value(value: _modulosBloc),
        BlocProvider<AutoevaluacionBloc>.value(value: _autoevaluacionBloc),
      ],
      child: MaterialApp(
        title: 'Alumni UCC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: _navigatorKey,
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
  void initState() {
    super.initState();
    print('🔗 AuthWrapper initialized');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, auth.AuthState>(
      listener: (context, state) {
        print('🎧 AuthWrapper BlocListener: ${state.runtimeType}');
        // Forzar reconstrucción cuando cambia a AuthUnauthenticated
        if (state is auth.AuthUnauthenticated) {
          print('🔄 AuthWrapper: Forzando reconstrucción por AuthUnauthenticated');
          setState(() {
            _showOnboarding = false; // Ir directo al login
          });
        }
      },
      child: BlocBuilder<AuthBloc, auth.AuthState>(
        buildWhen: (previous, current) {
          print('🔄 AuthWrapper buildWhen: ${previous.runtimeType} -> ${current.runtimeType}');
          // Siempre reconstruir cuando cambia el estado
          return true;
        },
        builder: (context, state) {
          print('🏠 AuthWrapper: Estado actual = ${state.runtimeType}');
          
          // Mostrar loading mientras se inicializa
          if (state is auth.AuthInitial || state is auth.AuthLoading) {
            print('⏳ AuthWrapper: Mostrando loading');
            return const FullScreenLoading(
              message: 'Iniciando Alumni UCC...',
            );
          }

        // Si está autenticado con perfil completo, ir directamente al home
        if (state is auth.AuthenticatedWithProfile) {
          return const HomeScreen();
        }

        // Si está autenticado pero sin perfil, mostrar onboarding primero
        if (state is auth.AuthenticatedWithoutProfile) {
          if (_showOnboarding) {
            return OnboardingScreen(
              onComplete: () {
                setState(() {
                  _showOnboarding = false;
                });
              },
            );
          }
          return const CompleteProfileScreen();
        }

        // Si hay error, mostrar onboarding
        if (state is auth.AuthError) {
          if (_showOnboarding) {
            return OnboardingScreen(
              onComplete: () {
                setState(() {
                  _showOnboarding = false;
                });
              },
            );
          }
          return const LoginScreen();
        }

        // Si no está autenticado, ir directo al login (sin onboarding)
        if (state is auth.AuthUnauthenticated) {
          print('🔓 AuthWrapper: Usuario no autenticado, mostrando LoginScreen');
          return const LoginScreen();
        }

        // Estado por defecto - mostrar onboarding
        if (_showOnboarding) {
          return OnboardingScreen(
            onComplete: () {
              setState(() {
                _showOnboarding = false;
              });
            },
          );
        }
        return const LoginScreen();
        },
      ),
    );
  }
}
