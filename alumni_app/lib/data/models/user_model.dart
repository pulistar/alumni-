import 'package:equatable/equatable.dart';

// Modelo de usuario autenticado
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final DateTime? emailConfirmedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.emailConfirmedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      emailConfirmedAt: json['email_confirmed_at'] != null
          ? DateTime.parse(json['email_confirmed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'email_confirmed_at': emailConfirmedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        emailConfirmedAt,
        createdAt,
        updatedAt,
      ];
}

// Modelo de egresado (perfil completo)
class EgresadoModel extends Equatable {
  final String id;
  final String uid;
  final String correo;
  final String nombre;
  final String apellido;
  final String? carreraId;
  final String? telefono;
  final String? ciudad;
  final String? estadoLaboralId;
  final String? empresaActual;
  final String? cargoActual;
  final bool habilitado;
  final bool procesoGradoCompleto;
  final bool autoevaluacionHabilitada;
  final bool autoevaluacionCompletada;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EgresadoModel({
    required this.id,
    required this.uid,
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.carreraId,
    this.telefono,
    this.ciudad,
    this.estadoLaboralId,
    this.empresaActual,
    this.cargoActual,
    required this.habilitado,
    required this.procesoGradoCompleto,
    required this.autoevaluacionHabilitada,
    required this.autoevaluacionCompletada,
    required this.createdAt,
    this.updatedAt,
  });

  factory EgresadoModel.fromJson(Map<String, dynamic> json) {
    return EgresadoModel(
      id: json['id'] as String,
      uid: json['uid'] as String,
      correo: json['correo'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      carreraId: json['carrera_id'] as String?,
      telefono: json['telefono'] as String?,
      ciudad: json['ciudad'] as String?,
      estadoLaboralId: json['estado_laboral_id'] as String?,
      empresaActual: json['empresa_actual'] as String?,
      cargoActual: json['cargo_actual'] as String?,
      habilitado: json['habilitado'] as bool? ?? false,
      procesoGradoCompleto: json['proceso_grado_completo'] as bool? ?? false,
      autoevaluacionHabilitada: json['autoevaluacion_habilitada'] as bool? ?? false,
      autoevaluacionCompletada: json['autoevaluacion_completada'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'carrera_id': carreraId,
      'telefono': telefono,
      'ciudad': ciudad,
      'estado_laboral_id': estadoLaboralId,
      'empresa_actual': empresaActual,
      'cargo_actual': cargoActual,
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
        id,
        uid,
        correo,
        nombre,
        apellido,
        carreraId,
        telefono,
        ciudad,
        estadoLaboralId,
        empresaActual,
        cargoActual,
        habilitado,
        procesoGradoCompleto,
        autoevaluacionHabilitada,
        autoevaluacionCompletada,
        createdAt,
        updatedAt,
      ];
}
