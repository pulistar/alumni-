import 'package:equatable/equatable.dart';

class PreguntaModel extends Equatable {
  final String id;
  final String texto;
  final String tipo; // 'likert', 'texto', 'seleccion_multiple'
  final int orden;
  final bool activa;
  final RespuestaModel? respuesta;

  const PreguntaModel({
    required this.id,
    required this.texto,
    required this.tipo,
    required this.orden,
    required this.activa,
    this.respuesta,
  });

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['id'] as String,
      texto: json['texto'] as String,
      tipo: json['tipo'] as String,
      orden: json['orden'] as int,
      activa: json['activa'] as bool? ?? true,
      respuesta: json['respuesta'] != null
          ? RespuestaModel.fromJson(json['respuesta'] as Map<String, dynamic>)
          : null,
    );
  }

  PreguntaModel copyWith({
    String? id,
    String? texto,
    String? tipo,
    int? orden,
    bool? activa,
    RespuestaModel? respuesta,
  }) {
    return PreguntaModel(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      tipo: tipo ?? this.tipo,
      orden: orden ?? this.orden,
      activa: activa ?? this.activa,
      respuesta: respuesta ?? this.respuesta,
    );
  }

  @override
  List<Object?> get props => [id, texto, tipo, orden, activa, respuesta];
}

class RespuestaModel extends Equatable {
  final String? id;
  final String? preguntaId;
  final String? respuestaTexto;
  final int? respuestaNumerica;

  const RespuestaModel({
    this.id,
    this.preguntaId,
    this.respuestaTexto,
    this.respuestaNumerica,
  });

  factory RespuestaModel.fromJson(Map<String, dynamic> json) {
    return RespuestaModel(
      id: json['id'] as String?,
      preguntaId: json['pregunta_id'] as String?,
      respuestaTexto: json['respuesta_texto'] as String?,
      respuestaNumerica: json['respuesta_numerica'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (preguntaId != null) 'pregunta_id': preguntaId,
      if (respuestaTexto != null) 'respuesta_texto': respuestaTexto,
      if (respuestaNumerica != null) 'respuesta_numerica': respuestaNumerica,
    };
  }

  @override
  List<Object?> get props => [id, preguntaId, respuestaTexto, respuestaNumerica];
}
