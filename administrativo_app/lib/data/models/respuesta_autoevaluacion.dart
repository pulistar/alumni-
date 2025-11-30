/// Respuesta Autoevaluacion Model
class RespuestaAutoevaluacion {
  final String id;
  final String egresadoId;
  final String preguntaId;
  final int? respuestaNumerica;
  final String? respuestaTexto;
  final Map<String, dynamic>? respuestaJson;
  final DateTime createdAt;
  
  // Datos relacionados
  final Map<String, dynamic>? egresado;
  final Map<String, dynamic>? pregunta;

  RespuestaAutoevaluacion({
    required this.id,
    required this.egresadoId,
    required this.preguntaId,
    this.respuestaNumerica,
    this.respuestaTexto,
    this.respuestaJson,
    required this.createdAt,
    this.egresado,
    this.pregunta,
  });

  factory RespuestaAutoevaluacion.fromJson(Map<String, dynamic> json) {
    return RespuestaAutoevaluacion(
      id: json['id'] as String,
      egresadoId: json['egresado_id'] as String,
      preguntaId: json['pregunta_id'] as String,
      respuestaNumerica: json['respuesta_numerica'] as int?,
      respuestaTexto: json['respuesta_texto'] as String?,
      respuestaJson: json['respuesta_json'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      egresado: json['egresado'] as Map<String, dynamic>?,
      pregunta: json['pregunta'] as Map<String, dynamic>?,
    );
  }
}
