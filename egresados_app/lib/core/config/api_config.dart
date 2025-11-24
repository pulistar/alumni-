import 'app_config.dart';

// API Configuration
class ApiConfig {
  // Base URL dinámico según entorno
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  // Endpoints
  static const String auth = '/auth';
  static const String egresados = '/egresados';
  static const String documentos = '/documentos';
  static const String notificaciones = '/notificaciones';
  static const String autoevaluacion = '/autoevaluacion';
  static const String modulos = '/modulos';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
