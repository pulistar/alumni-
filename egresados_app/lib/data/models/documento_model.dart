import 'package:equatable/equatable.dart';

class DocumentoModel extends Equatable {
  final String id;
  final String egresadoId;
  final String tipoDocumento;
  final String? descripcion;
  final String nombreArchivo;
  final String rutaArchivo;
  final int tamanoArchivo;
  final String mimeType;
  final DateTime fechaSubida;
  final DateTime? fechaActualizacion;

  const DocumentoModel({
    required this.id,
    required this.egresadoId,
    required this.tipoDocumento,
    this.descripcion,
    required this.nombreArchivo,
    required this.rutaArchivo,
    required this.tamanoArchivo,
    required this.mimeType,
    required this.fechaSubida,
    this.fechaActualizacion,
  });

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id'] as String,
      egresadoId: json['egresado_id'] as String,
      tipoDocumento: json['tipo_documento'] as String,
      descripcion: json['descripcion'] as String?,
      nombreArchivo: json['nombre_archivo'] as String,
      rutaArchivo: json['ruta_storage'] as String, // Backend usa 'ruta_storage'
      tamanoArchivo: json['tamano_bytes'] as int, // Backend usa 'tamano_bytes'
      mimeType: json['mime_type'] as String,
      fechaSubida: DateTime.parse(json['created_at'] as String), // Backend usa 'created_at'
      fechaActualizacion: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String) // Backend usa 'updated_at'
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'egresado_id': egresadoId,
      'tipo_documento': tipoDocumento,
      'descripcion': descripcion,
      'nombre_archivo': nombreArchivo,
      'ruta_archivo': rutaArchivo,
      'tamano_archivo': tamanoArchivo,
      'mime_type': mimeType,
      'fecha_subida': fechaSubida.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  String get tipoDocumentoDisplayName {
    switch (tipoDocumento) {
      case 'momento_ole':
        return 'Momento OLE';
      case 'datos_egresados':
        return 'Datos de Egresados';
      case 'bolsa_empleo':
        return 'Bolsa de Empleo';
      case 'otro':
        return 'Otro';
      default:
        return tipoDocumento;
    }
  }

  String get tamanoArchivoFormateado {
    if (tamanoArchivo < 1024) {
      return '${tamanoArchivo} B';
    } else if (tamanoArchivo < 1024 * 1024) {
      return '${(tamanoArchivo / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanoArchivo / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  bool get esPDF => mimeType == 'application/pdf';
  bool get esImagen => mimeType.startsWith('image/');

  @override
  List<Object?> get props => [
        id,
        egresadoId,
        tipoDocumento,
        descripcion,
        nombreArchivo,
        rutaArchivo,
        tamanoArchivo,
        mimeType,
        fechaSubida,
        fechaActualizacion,
      ];
}
