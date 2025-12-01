/// Carrera Model
class Carrera {
  final String id;
  final String nombre;
  final String? codigo;
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  Carrera({
    required this.id,
    required this.nombre,
    this.codigo,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String?,
      activa: json['activa'] as bool? ?? true,
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
      'activa': activa,
    };
  }
}
