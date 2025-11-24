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
  String get supabaseUrl => 'https://cqumdqgrcbrqlrmsfswg.supabase.co';
  
  @override
  String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxdW1kcWdyY2JycWxybXNmc3dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzQ4MDksImV4cCI6MjA3OTUxMDgwOX0.x4Nl5UyU135Ez8o5JGOCHl_je0PApwcLC82apwJP40A';
  
  @override
  String get apiBaseUrl {
    // Configurado para tu dispositivo físico
    return 'http://192.168.20.53:3000/api'; // ✅ Tu IP configurada
  }
  
  @override
  bool get isProduction => false;
  
  @override
  String get appName => 'Alumni UCC (Dev)';
}

// Entorno de producción
class ProductionEnvironment implements AppEnvironment {
  @override
  String get supabaseUrl => 'https://cqumdqgrcbrqlrmsfswg.supabase.co';
  
  @override
  String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxdW1kcWdyY2JycWxybXNmc3dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzQ4MDksImV4cCI6MjA3OTUxMDgwOX0.x4Nl5UyU135Ez8o5JGOCHl_je0PApwcLC82apwJP40A';
  
  @override
  String get apiBaseUrl => 'https://tu-api-produccion.com/api'; // TODO: Cambiar por tu URL de producción
  
  @override
  bool get isProduction => true;
  
  @override
  String get appName => 'Alumni UCC';
}

// Entorno de testing
class TestingEnvironment implements AppEnvironment {
  @override
  String get supabaseUrl => 'https://tu-proyecto-test.supabase.co';
  
  @override
  String get supabaseAnonKey => 'tu-anon-key-testing';
  
  @override
  String get apiBaseUrl => 'https://tu-api-testing.com/api';
  
  @override
  bool get isProduction => false;
  
  @override
  String get appName => 'Alumni UCC (Test)';
}
