import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Evento para inicializar la autenticación
class AuthInitialized extends AuthEvent {}

// Evento para enviar magic link
class AuthMagicLinkRequested extends AuthEvent {
  final String email;

  const AuthMagicLinkRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// Evento para verificar OTP
class AuthOTPVerified extends AuthEvent {
  final String email;
  final String token;

  const AuthOTPVerified({
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [email, token];
}

// Evento para completar perfil
class AuthProfileCompleted extends AuthEvent {
  final String nombre;
  final String apellido;
  final String idUniversitario;
  final String telefono;
  final String ciudad;
  final String? carreraId;
  final String? telefonoAlternativo;
  final String? direccion;
  final String? pais;
  final String? estadoLaboralId;
  final String? empresaActual;
  final String? cargoActual;
  final String? fechaGraduacion;
  final String? semestreGraduacion;
  final int? anioGraduacion;

  const AuthProfileCompleted({
    required this.nombre,
    required this.apellido,
    required this.idUniversitario,
    required this.telefono,
    required this.ciudad,
    this.carreraId,
    this.telefonoAlternativo,
    this.direccion,
    this.pais,
    this.estadoLaboralId,
    this.empresaActual,
    this.cargoActual,
    this.fechaGraduacion,
    this.semestreGraduacion,
    this.anioGraduacion,
  });

  @override
  List<Object?> get props => [
        nombre,
        apellido,
        idUniversitario,
        telefono,
        ciudad,
        carreraId,
        telefonoAlternativo,
        direccion,
        pais,
        estadoLaboralId,
        empresaActual,
        cargoActual,
        fechaGraduacion,
        semestreGraduacion,
        anioGraduacion,
      ];
}

// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {}

// Evento para refrescar perfil
class AuthProfileRefreshed extends AuthEvent {}

// Evento cuando cambia el estado de auth de Supabase
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated];
}
