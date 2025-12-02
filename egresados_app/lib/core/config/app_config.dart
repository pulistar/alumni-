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
      // Fallback a las credenciales de producción
      return 'https://cqumdqgrcbrqlrmsfswg.supabase.co';
    }
    return envUrl;
  }
  
  @override
  String get supabaseAnonKey {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isEmpty) {
      // Fallback a la key de producción
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxdW1kcWdyY2JycWxybXNmc3dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzQ4MDksImV4cCI6MjA3OTUxMDgwOX0.x4Nl5UyU135Ez8o5JGOCHl_je0PApwcLC82apwJP40A';
    }
    return envKey;
  }
  
  @override
  String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isEmpty) {
       // Valor por defecto apunta a producción en Render
       // Para desarrollo local, configura --dart-define en launch.json
       return 'https://alumni-backend-4ej0.onrender.com/api';
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
