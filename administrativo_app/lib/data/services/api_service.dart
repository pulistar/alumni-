import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';
import '../models/module.dart';
import '../models/egresado.dart';

/// API Service
/// Handles HTTP requests to the backend API
class ApiService {
  /// Login admin user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔵 Intentando login a: ${ApiConfig.loginUrl}');
      print('🔵 Email: ${request.email}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final message = jsonResponse['message'] as String? ?? 'Credenciales inválidas';
          throw Exception(message);
        } catch (e) {
          throw Exception('Credenciales inválidas');
        }
      } else {
        throw Exception('Error al iniciar sesión. Código: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw Exception('No se puede conectar al servidor');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión');
    }
  }

  /// Register new administrator
  Future<AuthResponse> register(String nombre, String apellido, String correo, String password) async {
    try {
      print('🔵 Intentando registro a: ${ApiConfig.baseUrl}/auth/register');
      print('🔵 Email: $correo');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'password': password,
          'confirmPassword': password,
        }),
      );

      print('🔵 Status Code: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        try {
          final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
          final message = jsonResponse['message'] as String? ?? 'Error en el registro';
          throw Exception(message);
        } catch (e) {
          throw Exception('Error en el registro');
        }
      } else {
        throw Exception('Error al registrarse. Código: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw Exception('No se puede conectar al servidor');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión');
    }
  }

  /// Get all modules
  Future<List<Module>> getModules({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/modulos'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((json) => Module.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener módulos. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener módulos');
    }
  }

  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return DashboardStats.fromJson(jsonResponse);
      } else {
        throw Exception('Error al obtener estadísticas');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener estadísticas');
    }
  }

  /// Get distribution of egresados by career
  Future<List<dynamic>> getDistribucionCarrera(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/analytics/distribucion-carrera'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener distribución por carrera');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener distribución');
    }
  }

  /// Get employment rate
  Future<Map<String, dynamic>> getTasaEmpleabilidad(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/analytics/tasa-empleabilidad'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener tasa de empleabilidad');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener tasa de empleabilidad');
    }
  }

  /// Get employment by career
  Future<List<dynamic>> getEmpleabilidadCarrera(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/analytics/empleabilidad-carrera'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener empleabilidad por carrera');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener empleabilidad');
    }
  }

  /// Get process funnel
  Future<List<dynamic>> getEmbudoProceso(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/analytics/embudo-proceso'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener embudo de proceso');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener embudo');
    }
  }

  /// Get competencies radar
  Future<List<dynamic>> getRadarCompetencias(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/analytics/radar-competencias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener radar de competencias');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener radar');
    }
  }

  /// Get egresados list with filters
  Future<Map<String, dynamic>> getEgresados({
    required String token,
    int page = 1,
    int limit = 20,
    bool? habilitado,
    String? carrera,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (habilitado != null) 'habilitado': habilitado.toString(),
        if (carrera != null && carrera.isNotEmpty) 'carrera': carrera,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/admin/egresados').replace(queryParameters: queryParams);

      print('🔵 GET Egresados: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔵 Egresados Status: ${response.statusCode}');
      print('🔵 Egresados Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as List<dynamic>;
        
        print('🔵 Found ${data.length} egresados');
        
        final egresados = data.map((json) => Egresado.fromJson(json as Map<String, dynamic>)).toList();
        
        return {
          'egresados': egresados,
          'total': jsonResponse['total'] as int,
          'page': jsonResponse['page'] as int,
          'totalPages': jsonResponse['totalPages'] as int,
        };
      } else {
        print('❌ Error status: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        throw Exception('Error al obtener egresados. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in getEgresados: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al obtener egresados');
    }
  }

  /// Get egresado detail
  Future<Egresado> getEgresadoDetail(String token, String id) async {
    try {
      print('🔵 GET Egresado Detail: $id');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔵 Detail Status: ${response.statusCode}');
      print('🔵 Detail Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        // Extract the 'perfil' object from the response
        final perfilData = jsonResponse['perfil'] as Map<String, dynamic>;
        return Egresado.fromJson(perfilData);
      } else {
        print('❌ Error status: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        throw Exception('Error al obtener detalle del egresado');
      }
    } catch (e) {
      print('❌ Exception in getEgresadoDetail: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al obtener detalle');
    }
  }

  /// Toggle egresado habilitado status
  Future<void> toggleEgresadoHabilitado(String token, String id, bool habilitado) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/$id/habilitar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'habilitado': habilitado}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar estado');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al actualizar');
    }
  }

  /// Upload Excel file to enable multiple egresados
  Future<Map<String, dynamic>> uploadExcelToEnableEgresados(String token, String filePath) async {
    try {
      print('🔵 Uploading Excel file: $filePath');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/habilitar-excel'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('🔵 Upload Status: ${response.statusCode}');
      print('🔵 Upload Response: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Error status: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        throw Exception('Error al procesar archivo Excel');
      }
    } catch (e) {
      print('❌ Exception in uploadExcelToEnableEgresados: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al subir archivo');
    }
  }

  // ==================== PREGUNTAS CRUD ====================

  /// Get all preguntas
  Future<List<dynamic>> getPreguntas(String token, {bool? activa}) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}/admin/preguntas');
      if (activa != null) {
        uri = Uri.parse('${ApiConfig.baseUrl}/admin/preguntas?activa=$activa');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener preguntas');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener preguntas');
    }
  }

  /// Create pregunta
  Future<Map<String, dynamic>> createPregunta(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/preguntas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al crear pregunta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al crear pregunta');
    }
  }

  /// Update pregunta
  Future<Map<String, dynamic>> updatePregunta(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/preguntas/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al actualizar pregunta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al actualizar pregunta');
    }
  }

  /// Toggle pregunta activa status
  Future<void> togglePregunta(String token, String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/preguntas/$id/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado de pregunta');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al cambiar estado');
    }
  }

  // ==================== DOCUMENTOS ====================

  /// Get documentos of egresado
  Future<List<dynamic>> getDocumentosEgresado(String token, String egresadoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/$egresadoId/documentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener documentos');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener documentos');
    }
  }

  // ==================== AUTOEVALUACIONES ====================

  /// Get autoevaluacion responses of egresado
  Future<List<dynamic>> getAutoevaluacionEgresado(String token, String egresadoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/$egresadoId/autoevaluacion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener autoevaluación');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener autoevaluación');
    }
  }

  // ==================== REPORTES ====================

  /// Get egresado autoevaluacion responses
  Future<List<dynamic>> getEgresadoAutoevaluacion(String token, String egresadoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/egresados/$egresadoId/autoevaluacion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        // Backend returns { egresado: {...}, respuestas: [...] }
        return (jsonResponse['respuestas'] as List<dynamic>?) ?? [];
      } else {
        throw Exception('Error al obtener autoevaluación');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener autoevaluación');
    }
  }

  /// Get unified PDFs list
  Future<Map<String, dynamic>> getPDFsUnificados(String token, {String? carrera}) async {
    try {
      final uri = carrera != null
          ? Uri.parse('${ApiConfig.baseUrl}/admin/reportes/pdfs-unificados?carrera=$carrera')
          : Uri.parse('${ApiConfig.baseUrl}/admin/reportes/pdfs-unificados');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener PDFs unificados');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener PDFs unificados');
    }
  }

  // ==================== REPORTES ====================

  /// Export egresados to Excel
  Future<List<int>> exportEgresadosExcel(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/reportes/egresados/excel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al exportar egresados');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al exportar');
    }
  }

  /// Export autoevaluaciones to Excel
  Future<List<int>> exportAutoevaluacionesExcel(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/reportes/autoevaluaciones/excel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al exportar autoevaluaciones');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al exportar');
    }
  }

  // ==================== MÓDULOS ====================

  /// Get all modulos
  Future<List<dynamic>> getModulos(String token, {bool? activo}) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}/admin/modulos');
      if (activo != null) {
        uri = Uri.parse('${ApiConfig.baseUrl}/admin/modulos?activo=$activo');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error al obtener módulos');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener módulos');
    }
  }

  /// Create modulo
  Future<Map<String, dynamic>> createModulo(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/modulos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al crear módulo');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al crear módulo');
    }
  }

  /// Update modulo
  Future<Map<String, dynamic>> updateModulo(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/modulos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al actualizar módulo');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al actualizar módulo');
    }
  }

  /// Toggle modulo activo status
  Future<void> toggleModulo(String token, String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/admin/modulos/$id/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar estado de módulo');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al cambiar estado');
    }
  }
}
