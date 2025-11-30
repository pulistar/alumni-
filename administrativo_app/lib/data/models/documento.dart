/// Documento Model
class Documento {
  final String id;
  final String egresadoId;
  final String tipoDocumento;
  final String nombreArchivo;
  final String? rutaArchivo;
  final String? urlFirmada;
  final String estado;
  final DateTime? fechaSubida;
  final DateTime? fechaValidacion;

  Documento({
    required this.id,
    required this.egresadoId,
    required this.tipoDocumento,
    required this.nombreArchivo,
    this.rutaArchivo,
    this.urlFirmada,
    required this.estado,
    this.fechaSubida,
    this.fechaValidacion,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as String,
      egresadoId: json['egresado_id'] as String,
      tipoDocumento: json['tipo_documento'] as String,
      nombreArchivo: json['nombre_archivo'] as String,
      rutaArchivo: json['ruta_archivo'] as String?,
      urlFirmada: json['url_firmada'] as String?,
      estado: json['estado'] as String? ?? 'pendiente',
      fechaSubida: json['fecha_subida'] != null
          ? DateTime.parse(json['fecha_subida'] as String)
          : null,
      fechaValidacion: json['fecha_validacion'] != null
          ? DateTime.parse(json['fecha_validacion'] as String)
          : null,
    );
  }
}
