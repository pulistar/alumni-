/// Pregunta Model
class Pregunta {
  final String id;
  final String texto;
  final String tipo;
  final Map<String, dynamic>? opciones;
  final int orden;
  final String? categoria;
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pregunta({
    required this.id,
    required this.texto,
    required this.tipo,
    this.opciones,
    required this.orden,
    this.categoria,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'] as String,
      texto: json['texto'] as String,
      tipo: json['tipo'] as String,
      opciones: json['opciones'] as Map<String, dynamic>?,
      orden: json['orden'] as int,
      categoria: json['categoria'] as String?,
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
      'texto': texto,
      'tipo': tipo,
      'opciones': opciones,
      'orden': orden,
      'categoria': categoria,
      'activa': activa,
    };
  }
}

/// Enum for question types
enum TipoPregunta {
  likert('likert', 'Escala Likert (1-5)'),
  texto('texto', 'Texto Libre'),
  multiple('multiple', 'Selección Múltiple');

  final String value;
  final String label;

  const TipoPregunta(this.value, this.label);

  static TipoPregunta fromString(String value) {
    return TipoPregunta.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoPregunta.likert,
    );
  }
}
