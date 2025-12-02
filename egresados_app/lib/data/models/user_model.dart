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
  final String correoInstitucional;
  final String nombre;
  final String apellido;
  final String idUniversitario;
  final String carreraId;
  final String celular;
  final String? telefonoAlternativo;
  final String correoPersonal;
  final String tipoDocumentoId;
  final String documento;
  final String lugarExpedicion;
  final String gradoAcademicoId;
  final bool habilitado;
  final bool procesoGradoCompleto;
  final bool autoevaluacionHabilitada;
  final bool autoevaluacionCompletada;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EgresadoModel({
    required this.id,
    required this.uid,
    required this.correoInstitucional,
    required this.nombre,
    required this.apellido,
    required this.idUniversitario,
    required this.carreraId,
    required this.celular,
    this.telefonoAlternativo,
    required this.correoPersonal,
    required this.tipoDocumentoId,
    required this.documento,
    required this.lugarExpedicion,
    required this.gradoAcademicoId,
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
      correoInstitucional: json['correo_institucional'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      idUniversitario: json['id_universitario'] as String,
      carreraId: json['carrera_id'] as String,
      celular: json['celular'] as String,
      telefonoAlternativo: json['telefono_alternativo'] as String?,
      correoPersonal: json['correo_personal'] as String,
      tipoDocumentoId: json['tipo_documento_id'] as String,
      documento: json['documento'] as String,
      lugarExpedicion: json['lugar_expedicion'] as String,
      gradoAcademicoId: json['grado_academico_id'] as String,
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
      'id': id,
      'uid': uid,
      'correo_institucional': correoInstitucional,
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
      'habilitado': habilitado,
      'proceso_grado_completo': procesoGradoCompleto,
      'autoevaluacion_habilitada': autoevaluacionHabilitada,
      'autoevaluacion_completada': autoevaluacionCompletada,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
        id,
        uid,
        correoInstitucional,
        nombre,
        apellido,
        idUniversitario,
        carreraId,
        celular,
        telefonoAlternativo,
        correoPersonal,
        tipoDocumentoId,
        documento,
        lugarExpedicion,
        gradoAcademicoId,
        habilitado,
        procesoGradoCompleto,
        autoevaluacionHabilitada,
        autoevaluacionCompletada,
        createdAt,
        updatedAt,
      ];
}
