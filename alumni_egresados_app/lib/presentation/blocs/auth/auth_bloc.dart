import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart' as auth;

class AuthBloc extends Bloc<AuthEvent, auth.AuthState> {
  final AuthService _authService;
  late StreamSubscription<AuthState> _authSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(auth.AuthInitial()) {
    
    // Registrar manejadores de eventos
    on<AuthInitialized>(_onAuthInitialized);
    on<AuthMagicLinkRequested>(_onMagicLinkRequested);
    on<AuthOTPVerified>(_onOTPVerified);
    on<AuthProfileCompleted>(_onProfileCompleted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthProfileRefreshed>(_onProfileRefreshed);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Escuchar cambios de autenticación de Supabase
    _authSubscription = _authService.authStateChanges.listen((authState) {
      add(AuthStateChanged(isAuthenticated: authState.session != null));
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  // Inicializar autenticación
  Future<void> _onAuthInitialized(
    AuthInitialized event,
    Emitter<auth.AuthState> emit,
  ) async {
    emit(auth.AuthLoading());

    try {
      if (_authService.isAuthenticated) {
        final user = _authService.currentUser!;
        final userModel = UserModel(
          id: user.id,
          email: user.email!,
          phone: user.phone,
          emailConfirmedAt: user.emailConfirmedAt != null ? DateTime.parse(user.emailConfirmedAt!) : null,
          createdAt: DateTime.parse(user.createdAt),
          updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
        );

        // Intentar obtener perfil de egresado
        final egresado = await _authService.getEgresadoProfile();
        
        if (egresado != null) {
          emit(auth.AuthenticatedWithProfile(user: userModel, egresado: egresado));
        } else {
          emit(auth.AuthenticatedWithoutProfile(user: userModel));
        }
      } else {
        emit(auth.AuthUnauthenticated());
      }
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Enviar magic link
  Future<void> _onMagicLinkRequested(
    AuthMagicLinkRequested event,
    Emitter<auth.AuthState> emit,
  ) async {
    emit(auth.AuthLoading());

    try {
      await _authService.sendMagicLink(event.email);
      emit(auth.AuthMagicLinkSent(email: event.email));
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Verificar OTP
  Future<void> _onOTPVerified(
    AuthOTPVerified event,
    Emitter<auth.AuthState> emit,
  ) async {
    emit(auth.AuthLoading());

    try {
      final response = await _authService.verifyOTP(
        email: event.email,
        token: event.token,
      );

      if (response.user != null) {
        final userModel = UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          phone: response.user!.phone,
          emailConfirmedAt: response.user!.emailConfirmedAt != null ? DateTime.parse(response.user!.emailConfirmedAt!) : null,
          createdAt: DateTime.parse(response.user!.createdAt),
          updatedAt: response.user!.updatedAt != null ? DateTime.parse(response.user!.updatedAt!) : null,
        );

        // Verificar si tiene perfil completo
        final egresado = await _authService.getEgresadoProfile();
        
        if (egresado != null) {
          emit(auth.AuthenticatedWithProfile(user: userModel, egresado: egresado));
        } else {
          emit(auth.AuthenticatedWithoutProfile(user: userModel));
        }
      } else {
        emit(const auth.AuthError(message: 'Error en la verificación'));
      }
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Completar perfil
  Future<void> _onProfileCompleted(
    AuthProfileCompleted event,
    Emitter<auth.AuthState> emit,
  ) async {
    if (state is! auth.AuthenticatedWithoutProfile) return;

    final currentState = state as auth.AuthenticatedWithoutProfile;
    emit(auth.AuthCompletingProfile(user: currentState.user));

    try {
      final egresado = await _authService.completeProfile(
        nombre: event.nombre,
        apellido: event.apellido,
        idUniversitario: event.idUniversitario,
        telefono: event.telefono,
        ciudad: event.ciudad,
        carreraId: event.carreraId,
        telefonoAlternativo: event.telefonoAlternativo,
        direccion: event.direccion,
        pais: event.pais,
        estadoLaboralId: event.estadoLaboralId,
        empresaActual: event.empresaActual,
        cargoActual: event.cargoActual,
        fechaGraduacion: event.fechaGraduacion,
        semestreGraduacion: event.semestreGraduacion,
        anioGraduacion: event.anioGraduacion,
      );

      emit(auth.AuthenticatedWithProfile(
        user: currentState.user,
        egresado: egresado,
      ));
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Cerrar sesión
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<auth.AuthState> emit,
  ) async {
    emit(auth.AuthLoading());

    try {
      await _authService.signOut();
      emit(auth.AuthUnauthenticated());
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Refrescar perfil
  Future<void> _onProfileRefreshed(
    AuthProfileRefreshed event,
    Emitter<auth.AuthState> emit,
  ) async {
    if (state is! auth.AuthenticatedWithProfile) return;

    final currentState = state as auth.AuthenticatedWithProfile;

    try {
      final egresado = await _authService.getEgresadoProfile();
      
      if (egresado != null) {
        emit(auth.AuthenticatedWithProfile(
          user: currentState.user,
          egresado: egresado,
        ));
      }
    } catch (e) {
      emit(auth.AuthError(message: e.toString()));
    }
  }

  // Cambio de estado de autenticación
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<auth.AuthState> emit,
  ) async {
    if (!event.isAuthenticated) {
      emit(auth.AuthUnauthenticated());
    } else {
      // Re-evaluar el estado cuando se autentica
      add(AuthInitialized());
    }
  }
}
