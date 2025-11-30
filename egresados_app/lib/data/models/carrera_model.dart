class CarreraModel {
  final String id;
  final String nombre;
  final String? codigo;

  CarreraModel({
    required this.id,
    required this.nombre,
    this.codigo,
  });

  factory CarreraModel.fromJson(Map<String, dynamic> json) {
    return CarreraModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
    };
  }
}
