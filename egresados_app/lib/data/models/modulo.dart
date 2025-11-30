class Modulo {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int orden;
  final bool activo;
  final String? ruta;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Modulo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.orden,
    required this.activo,
    this.ruta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Modulo.fromJson(Map<String, dynamic> json) {
    return Modulo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      icono: json['icono'] as String,
      orden: json['orden'] as int,
      activo: json['activo'] as bool,
      ruta: json['ruta'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'orden': orden,
      'activo': activo,
      'ruta': ruta,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Modulo(id: $id, nombre: $nombre, activo: $activo, orden: $orden)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Modulo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
