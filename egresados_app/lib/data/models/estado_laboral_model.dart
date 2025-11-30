class EstadoLaboralModel {
  final String id;
  final String nombre;

  EstadoLaboralModel({
    required this.id,
    required this.nombre,
  });

  factory EstadoLaboralModel.fromJson(Map<String, dynamic> json) {
    return EstadoLaboralModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
