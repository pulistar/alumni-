import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carga
class AuthLoading extends AuthState {}

// Estado no autenticado
class AuthUnauthenticated extends AuthState {}

// Estado autenticado pero sin perfil completo
class AuthenticatedWithoutProfile extends AuthState {
  final UserModel user;

  const AuthenticatedWithoutProfile({required this.user});

  @override
  List<Object> get props => [user];
}

// Estado autenticado con perfil completo
class AuthenticatedWithProfile extends AuthState {
  final UserModel user;
  final EgresadoModel egresado;

  const AuthenticatedWithProfile({
    required this.user,
    required this.egresado,
  });

  @override
  List<Object> get props => [user, egresado];
}

// Estado de magic link enviado
class AuthMagicLinkSent extends AuthState {
  final String email;

  const AuthMagicLinkSent({required this.email});

  @override
  List<Object> get props => [email];
}

// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Estado de completando perfil
class AuthCompletingProfile extends AuthState {
  final UserModel user;

  const AuthCompletingProfile({required this.user});

  @override
  List<Object> get props => [user];
}
