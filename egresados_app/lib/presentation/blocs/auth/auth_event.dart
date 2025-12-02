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
  final String celular;
  final String? telefonoAlternativo;
  final String correoPersonal;
  final String tipoDocumentoId;
  final String documento;
  final String lugarExpedicion;
  final String gradoAcademicoId;
  final String carreraId;

  const AuthProfileCompleted({
    required this.nombre,
    required this.apellido,
    required this.idUniversitario,
    required this.celular,
    this.telefonoAlternativo,
    required this.correoPersonal,
    required this.tipoDocumentoId,
    required this.documento,
    required this.lugarExpedicion,
    required this.gradoAcademicoId,
    required this.carreraId,
  });

  @override
  List<Object?> get props => [
        nombre,
        apellido,
        idUniversitario,
        celular,
        telefonoAlternativo,
        correoPersonal,
        tipoDocumentoId,
        documento,
        lugarExpedicion,
        gradoAcademicoId,
        carreraId,
      ];
}

// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {}

class AuthProfileRefreshRequested extends AuthEvent {}

// Evento para refrescar perfil
class AuthProfileRefreshed extends AuthEvent {}

// Evento cuando cambia el estado de auth de Supabase
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({required this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated];
}
