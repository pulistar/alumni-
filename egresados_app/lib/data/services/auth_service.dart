import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/config/api_config.dart';
import '../../services/notification_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService();

  // Constructor
  AuthService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    
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

  // Obtener usuario actual
  User? get currentUser => _supabase.auth.currentUser;
  
  // Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // Verificar si está autenticado
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  
  // Obtener token de acceso
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  // Enviar Magic Link
  Future<AuthResponse> sendMagicLink(String email) async {
    try {
      print('📧 Enviando magic link a: $email');
      print('📧 URL: ${ApiConfig.baseUrl}${ApiConfig.auth}/magic-link');
      
      // Enviar solicitud al backend, que se encarga de llamar a Supabase
      final response = await _dio.post(
        ApiConfig.auth + '/magic-link',
        data: {'email': email},
      );

      print('📧 Respuesta: ${response.statusCode}');
      print('📧 Data: ${response.data}');

      if (response.statusCode == 200) {
        return AuthResponse();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status: ${e.response?.statusCode}');
      // Propagar el error del backend al caller para que pueda mostrar un mensaje adecuado
      final backendMessage = e.response?.data ?? e.message;
      throw Exception('Error enviando magic link: $backendMessage');
    } catch (e) {
      print('❌ Error general: $e');
      throw Exception('Error enviando magic link: $e');
    }
  }

  // Verificar OTP
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      if (response.session != null) {
        await initializeNotifications();
      }

      return response;
    } catch (e) {
      throw Exception('Error verificando OTP: $e');
    }
  }

  // Inicializar notificaciones y actualizar token
  Future<void> initializeNotifications() async {
    try {
      await _notificationService.initialize();
      final token = await _notificationService.getToken();
      if (token != null) {
        await _updateFcmToken(token);
      }
    } catch (e) {
      print('❌ Error inicializando notificaciones en AuthService: $e');
    }
  }

  // Actualizar token FCM en backend
  Future<void> _updateFcmToken(String fcmToken) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Actualizar directamente en Supabase o a través de tu API si prefieres
      // Usando Supabase directo ya que tenemos RLS configurado
      await _supabase
          .from('egresados')
          .update({'fcm_token': fcmToken})
          .eq('id', userId); // Asumiendo que el ID del egresado es el mismo que el user_id
          
      print('✅ FCM Token actualizado en el backend');
    } catch (e) {
      print('❌ Error actualizando FCM token: $e');
      // Intentar buscar el egresado por user_id si falla por id
      try {
         final userId = _supabase.auth.currentUser?.id;
         if (userId != null) {
            await _supabase
            .from('egresados')
            .update({'fcm_token': fcmToken})
            .eq('user_id', userId);
         }
      } catch (e2) {
         print('❌ Error re-intentando actualizar FCM token: $e2');
      }
    }
  }

  // Obtener perfil de egresado
  Future<EgresadoModel?> getEgresadoProfile() async {
    try {
      final response = await _dio.get(ApiConfig.egresados + '/me');
      
      if (response.statusCode == 200) {
        return EgresadoModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Perfil no encontrado - necesita completar perfil
        return null;
      }
      throw Exception('Error obteniendo perfil: ${e.message}');
    }
  }

  // Completar perfil de egresado
  Future<EgresadoModel> completeProfile({
    required String nombre,
    required String apellido,
    required String idUniversitario,
    required String celular,
    String? telefonoAlternativo,
    required String correoPersonal,
    required String tipoDocumentoId,
    required String documento,
    required String lugarExpedicion,
    required String gradoAcademicoId,
    required String carreraId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.egresados + '/completar-perfil',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'id_universitario': idUniversitario,
          'carrera_id': carreraId,
          'celular': celular,
          'telefono_alternativo': telefonoAlternativo,
          'correo_personal': correoPersonal,
          'tipo_documento_id': tipoDocumentoId,
          'documento': documento,
          'lugar_expedicion': lugarExpedicion,
          'grado_academico_id': gradoAcademicoId,
        },
      );

      if (response.statusCode == 201) {
        return EgresadoModel.fromJson(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error completando perfil: ${e.response?.data ?? e.message}');
    }
  }

  // Actualizar perfil
  Future<EgresadoModel> updateProfile({
    String? nombre,
    String? apellido,
    String? celular,
    String? telefonoAlternativo,
    String? correoPersonal,
    String? carreraId,
    String? gradoAcademicoId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (apellido != null) data['apellido'] = apellido;
      if (celular != null) data['celular'] = celular;
      if (telefonoAlternativo != null) data['telefono_alternativo'] = telefonoAlternativo;
      if (correoPersonal != null) data['correo_personal'] = correoPersonal;
      if (carreraId != null) data['carrera_id'] = carreraId;
      if (gradoAcademicoId != null) data['grado_academico_id'] = gradoAcademicoId;

      final response = await _dio.patch(
        ApiConfig.egresados + '/me',
        data: data,
      );

      if (response.statusCode == 200) {
        return EgresadoModel.fromJson(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error actualizando perfil: ${e.response?.data ?? e.message}');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error cerrando sesión: $e');
    }
  }

  // Refrescar sesión
  Future<AuthResponse> refreshSession() async {
    try {
      return await _supabase.auth.refreshSession();
    } catch (e) {
      throw Exception('Error refrescando sesión: $e');
    }
  }

  // Obtener lista de carreras
  Future<List<Map<String, dynamic>>> getCarreras() async {
    try {
      final response = await _dio.get(
        ApiConfig.egresados + '/carreras',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error obteniendo carreras: ${e.response?.data ?? e.message}');
    }
  }

  // Obtener lista de estados laborales
  Future<List<Map<String, dynamic>>> getEstadosLaborales() async {
    try {
      final response = await _dio.get(
        ApiConfig.egresados + '/estados-laborales',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error obteniendo estados laborales: ${e.response?.data ?? e.message}');
    }
  }

  // Obtener lista de grados académicos
  Future<List<Map<String, dynamic>>> getGradosAcademicos() async {
    try {
      final response = await _dio.get(
        ApiConfig.egresados + '/grados-academicos',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error obteniendo grados académicos: ${e.response?.data ?? e.message}');
    }
  }

  // Obtener lista de tipos de documento
  Future<List<Map<String, dynamic>>> getTiposDocumento() async {
    try {
      final response = await _dio.get(
        ApiConfig.egresados + '/tipos-documento',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error obteniendo tipos de documento: ${e.response?.data ?? e.message}');
    }
  }
}
