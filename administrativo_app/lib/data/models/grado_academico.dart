/// Grado Académico Model
class GradoAcademico {
  final String id;
  final String nombre;
  final String? codigo;
  final int? nivel;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradoAcademico({
    required this.id,
    required this.nombre,
    this.codigo,
    this.nivel,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradoAcademico.fromJson(Map<String, dynamic> json) {
    return GradoAcademico(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String?,
      nivel: json['nivel'] as int?,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'nivel': nivel,
      'activo': activo,
    };
  }

  String get nivelDescripcion {
    switch (nivel) {
      case 1:
        return 'Auxiliar';
      case 2:
        return 'Técnico';
      case 3:
        return 'Tecnólogo';
      case 4:
        return 'Pregrado';
      case 5:
        return 'Especialización';
      case 6:
        return 'Maestría';
      case 7:
        return 'Doctorado';
      default:
        return 'Otro';
    }
  }
}
