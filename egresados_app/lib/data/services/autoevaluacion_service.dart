import 'package:dio/dio.dart';
import '../models/autoevaluacion_model.dart';
import '../../core/config/api_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AutoevaluacionService {
  final Dio _dio;
  final SupabaseClient _supabase;

  AutoevaluacionService(this._dio, this._supabase);

  // Obtener preguntas y respuestas previas
  Future<List<PreguntaModel>> getPreguntas() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.autoevaluacion}/preguntas',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PreguntaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Guardar una respuesta
  Future<RespuestaModel> guardarRespuesta(String preguntaId, dynamic respuesta) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      final Map<String, dynamic> data = {
        'pregunta_id': preguntaId,
      };

      if (respuesta is int) {
        data['respuesta_numerica'] = respuesta;
      } else if (respuesta is String) {
        data['respuesta_texto'] = respuesta;
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.autoevaluacion}/respuesta',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RespuestaModel.fromJson(response.data);
      } else {
        throw Exception('Error al guardar respuesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener progreso
  Future<Map<String, dynamic>> getProgreso() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.autoevaluacion}/progreso',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener progreso: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Completar autoevaluación
  Future<void> completarAutoevaluacion() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.autoevaluacion}/completar',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al completar autoevaluación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
