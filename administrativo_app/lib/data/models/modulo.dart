/// Modulo Model
class Modulo {
  final String id;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Modulo({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Modulo.fromJson(Map<String, dynamic> json) {
    return Modulo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      orden: json['orden'] as int,
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
      'descripcion': descripcion,
      'orden': orden,
      'activo': activo,
    };
  }
}
