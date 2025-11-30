import 'dart:io';
import 'package:dio/dio.dart' hide MultipartFile;
import 'package:dio/dio.dart' as dio show MultipartFile;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/documento_model.dart';

enum TipoDocumento {
  momentoOle('momento_ole', 'Momento OLE'),
  datosEgresados('datos_egresados', 'Datos de Egresados'),
  bolsaEmpleo('bolsa_empleo', 'Bolsa de Empleo'),
  otro('otro', 'Otro');

  const TipoDocumento(this.value, this.displayName);
  final String value;
  final String displayName;
}

class DocumentosService {
  final Dio _dio = Dio();
  final SupabaseClient _supabase = Supabase.instance.client;

  DocumentosService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 30000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    
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

  Future<Map<String, dynamic>> uploadDocumento({
    required File file,
    required TipoDocumento tipoDocumento,
    String? descripcion,
  }) async {
    try {
      print('📄 Subiendo documento: ${file.path}');
      print('📄 Tipo: ${tipoDocumento.displayName}');
      
      // Crear FormData
      final formData = FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'tipo_documento': tipoDocumento.value,
        if (descripcion != null && descripcion.isNotEmpty)
          'descripcion': descripcion,
      });

      final response = await _dio.post(
        '/documentos/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📄 Respuesta upload: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('✅ Documento subido exitosamente');
        return response.data;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException subiendo documento: ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      throw Exception('Error subiendo documento: ${e.message}');
    } catch (e) {
      print('❌ Error general subiendo documento: $e');
      throw Exception('Error subiendo documento: $e');
    }
  }

  Future<List<DocumentoModel>> getDocumentos() async {
    try {
      print('📄 Obteniendo documentos del usuario');
      
      final response = await _dio.get('/documentos');
      
      print('📄 Respuesta documentos: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📄 Documentos obtenidos: ${data.length}');
        
        return data.map((doc) => DocumentoModel.fromJson(doc)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException obteniendo documentos: ${e.message}');
      throw Exception('Error obteniendo documentos: ${e.message}');
    } catch (e) {
      print('❌ Error general obteniendo documentos: $e');
      throw Exception('Error obteniendo documentos: $e');
    }
  }

  Future<String> getDownloadUrl(String documentoId) async {
    try {
      print('📄 Obteniendo URL de descarga para documento: $documentoId');
      
      final response = await _dio.get('/documentos/$documentoId/download');
      
      if (response.statusCode == 200) {
        final String url = response.data['url'];
        print('📄 URL obtenida exitosamente');
        return url;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException obteniendo URL: ${e.message}');
      throw Exception('Error obteniendo URL de descarga: ${e.message}');
    } catch (e) {
      print('❌ Error general obteniendo URL: $e');
      throw Exception('Error obteniendo URL de descarga: $e');
    }
  }

  Future<void> deleteDocumento(String documentoId) async {
    try {
      print('📄 Eliminando documento: $documentoId');
      
      final response = await _dio.delete('/documentos/$documentoId');
      
      if (response.statusCode == 200) {
        print('✅ Documento eliminado exitosamente');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException eliminando documento: ${e.message}');
      throw Exception('Error eliminando documento: ${e.message}');
    } catch (e) {
      print('❌ Error general eliminando documento: $e');
      throw Exception('Error eliminando documento: $e');
    }
  }

  Future<String> getUnifiedPDF() async {
    try {
      print('📄 Obteniendo PDF unificado');
      
      final response = await _dio.get('/documentos/unificado/download');
      
      if (response.statusCode == 200) {
        final String url = response.data['url'];
        print('📄 PDF unificado obtenido exitosamente');
        return url;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException obteniendo PDF unificado: ${e.message}');
      throw Exception('Error obteniendo PDF unificado: ${e.message}');
    } catch (e) {
      print('❌ Error general obteniendo PDF unificado: $e');
      throw Exception('Error obteniendo PDF unificado: $e');
    }
  }
}
