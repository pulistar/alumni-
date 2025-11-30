import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class EstadosLaboralesService {
  final Dio _dio = Dio();
  final SupabaseClient _supabase = Supabase.instance.client;

  EstadosLaboralesService() {
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

  Future<List<Map<String, dynamic>>> getEstadosLaborales() async {
    try {
      print('💼 Obteniendo estados laborales desde: ${AppConfig.apiBaseUrl}/egresados/estados-laborales');
      
      final response = await _dio.get('/egresados/estados-laborales');
      
      print('💼 Respuesta estados laborales: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('💼 Estados laborales obtenidos: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException obteniendo estados laborales: ${e.message}');
      throw Exception('Error obteniendo estados laborales: ${e.message}');
    } catch (e) {
      print('❌ Error general obteniendo estados laborales: $e');
      throw Exception('Error obteniendo estados laborales: $e');
    }
  }

  Future<String?> getEstadoLaboralNombre(String estadoId) async {
    try {
      final estados = await getEstadosLaborales();
      final estado = estados.firstWhere(
        (estado) => estado['id'] == estadoId,
        orElse: () => {},
      );
      
      return estado.isNotEmpty ? estado['nombre'] as String? : null;
    } catch (e) {
      print('❌ Error obteniendo nombre de estado laboral: $e');
      return null;
    }
  }
}
