import 'app_config.dart';

class SupabaseConfig {
  // URLs y keys dinámicas según el entorno
  static String get url => AppConfig.supabaseUrl;
  static String get anonKey => AppConfig.supabaseAnonKey;
  
  // Configuración adicional
  static const String authCallbackUrl = 'io.supabase.alumni://login-callback/';
  static const Duration authTimeout = Duration(seconds: 60);
  
  // Configuración de auth
  static const bool persistSession = true;
  static const bool autoRefreshToken = true;
}
