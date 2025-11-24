import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/config/api_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();

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
      // Primero intentar con el backend
      final response = await _dio.post(
        ApiConfig.auth + '/magic-link',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        // Si el backend responde OK, usar Supabase para enviar el magic link
        await _supabase.auth.signInWithOtp(
          email: email,
          emailRedirectTo: 'io.supabase.alumni://login-callback/',
        );
        return AuthResponse();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Si falla el backend, usar Supabase directamente
      print('Backend no disponible, usando Supabase directamente: ${e.message}');
      
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.alumni://login-callback/',
      );
      return AuthResponse();
    } catch (e) {
      throw Exception('Error enviando magic link: $e');
    }
  }

  // Verificar OTP
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      return await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );
    } catch (e) {
      throw Exception('Error verificando OTP: $e');
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
    required String telefono,
    required String ciudad,
    String? carreraId,
    String? telefonoAlternativo,
    String? direccion,
    String? pais,
    String? estadoLaboralId,
    String? empresaActual,
    String? cargoActual,
    String? fechaGraduacion,
    String? semestreGraduacion,
    int? anioGraduacion,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.egresados + '/completar-perfil',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'id_universitario': idUniversitario,
          'carrera_id': carreraId,
          'telefono': telefono,
          'telefono_alternativo': telefonoAlternativo,
          'direccion': direccion,
          'ciudad': ciudad,
          'pais': pais ?? 'Colombia',
          'estado_laboral_id': estadoLaboralId,
          'empresa_actual': empresaActual,
          'cargo_actual': cargoActual,
          'fecha_graduacion': fechaGraduacion,
          'semestre_graduacion': semestreGraduacion,
          'anio_graduacion': anioGraduacion,
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
    String? carreraId,
    String? telefono,
    String? ciudad,
    String? estadoLaboralId,
    String? empresaActual,
    String? cargoActual,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (apellido != null) data['apellido'] = apellido;
      if (carreraId != null) data['carrera_id'] = carreraId;
      if (telefono != null) data['telefono'] = telefono;
      if (ciudad != null) data['ciudad'] = ciudad;
      if (estadoLaboralId != null) data['estado_laboral_id'] = estadoLaboralId;
      if (empresaActual != null) data['empresa_actual'] = empresaActual;
      if (cargoActual != null) data['cargo_actual'] = cargoActual;

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
}
