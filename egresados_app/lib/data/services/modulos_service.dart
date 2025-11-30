import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/modulo.dart';

class ModulosService {
  final Dio _dio;

  ModulosService({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtener todos los módulos del sistema
  Future<List<Modulo>> getModulos() async {
    try {
      // Obtener token de autenticación de Supabase
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      print('📱 Obteniendo módulos desde: ${AppConfig.apiBaseUrl}/modulos');
      
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/modulos',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      print('📱 Respuesta módulos: ${response.statusCode}');
      print('📱 Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> modulosJson = response.data;
        return modulosJson.map((json) => Modulo.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener módulos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
        print('❌ Status: ${e.response?.statusCode}');
      }
      throw Exception('Error obteniendo módulos: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado: $e');
      throw Exception('Error inesperado obteniendo módulos: $e');
    }
  }
}
