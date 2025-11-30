import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class CarrerasService {
  final Dio _dio = Dio();
  final SupabaseClient _supabase = Supabase.instance.client;

  CarrerasService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    
    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _supabase.auth.currentSession?.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getCarreras() async {
    try {
      print('📚 Obteniendo carreras desde: ${AppConfig.apiBaseUrl}/egresados/carreras');
      
      final response = await _dio.get('/egresados/carreras');
      
      print('📚 Respuesta carreras: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📚 Carreras obtenidas: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException obteniendo carreras: ${e.message}');
      throw Exception('Error obteniendo carreras: ${e.message}');
    } catch (e) {
      print('❌ Error general obteniendo carreras: $e');
      throw Exception('Error obteniendo carreras: $e');
    }
  }

  Future<String?> getCarreraNombre(String carreraId) async {
    try {
      final carreras = await getCarreras();
      final carrera = carreras.firstWhere(
        (carrera) => carrera['id'] == carreraId,
        orElse: () => {},
      );
      
      return carrera.isNotEmpty ? carrera['nombre'] as String? : null;
    } catch (e) {
      print('❌ Error obteniendo nombre de carrera: $e');
      return null;
    }
  }
}
