import '../utils/platform_utils.dart';

// Configuración de la aplicación por entornos
abstract class AppConfig {
  static late AppEnvironment _environment;
  
  // Inicializar entorno
  static void initialize(AppEnvironment environment) {
    _environment = environment;
  }
  
  // Getters para acceder a la configuración actual
  static String get supabaseUrl => _environment.supabaseUrl;
  static String get supabaseAnonKey => _environment.supabaseAnonKey;
  static String get apiBaseUrl => _environment.apiBaseUrl;
  static bool get isProduction => _environment.isProduction;
  static String get appName => _environment.appName;
}

// Clase base para entornos
abstract class AppEnvironment {
  String get supabaseUrl;
  String get supabaseAnonKey;
  String get apiBaseUrl;
  bool get isProduction;
  String get appName;
}

// Entorno de desarrollo
class DevelopmentEnvironment implements AppEnvironment {
  @override
  String get supabaseUrl {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isEmpty) {
      throw Exception('⚠️ SUPABASE_URL no encontrada. Configura --dart-define o launch.json');
    }
    return envUrl;
  }
  
  @override
  String get supabaseAnonKey {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isEmpty) {
      throw Exception('⚠️ SUPABASE_ANON_KEY no encontrada. Configura --dart-define o launch.json');
    }
    return envKey;
  }
  
  @override
  String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isEmpty) {
       // Valor por defecto SOLO para la URL local de desarrollo (ngrok cambia mucho)
       // Esto es menos crítico que las keys de Supabase, pero idealmente también debería ir por env
       return 'https://aditya-pedimented-adela.ngrok-free.dev/api';
    }
    return envUrl;
  }
  
  @override
  bool get isProduction => false;
  
  @override
  String get appName => 'Alumni UCC (Dev)';
}

// Entorno de producción
class ProductionEnvironment implements AppEnvironment {
  @override
  String get supabaseUrl {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isEmpty) {
      throw Exception('CRÍTICO: SUPABASE_URL no configurada para producción.');
    }
    return envUrl;
  }
  
  @override
  String get supabaseAnonKey {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isEmpty) {
      throw Exception('CRÍTICO: SUPABASE_ANON_KEY no configurada para producción.');
    }
    return envKey;
  }
  
  @override
  String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isEmpty) {
      throw Exception('CRÍTICO: API_BASE_URL no configurada para producción.');
    }
    return envUrl;
  }
  
  @override
  bool get isProduction => true;
  
  @override
  String get appName => 'Alumni UCC';
}

// Entorno de testing
class TestingEnvironment implements AppEnvironment {
  @override
  String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL_TEST', defaultValue: '');
  
  @override
  String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_ANON_KEY_TEST', defaultValue: '');
  
  @override
  String get apiBaseUrl => const String.fromEnvironment('API_BASE_URL_TEST', defaultValue: '');
  
  @override
  bool get isProduction => false;
  
  @override
  String get appName => 'Alumni UCC (Test)';
}
