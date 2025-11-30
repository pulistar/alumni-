/// Egresado Model
class Egresado {
  final String id;
  final String correo;
  final String nombre;
  final String apellido;
  final String? idUniversitario;
  final String? carrera;
  final String? telefono;
  final String? ciudad;
  final String? estadoLaboral;
  final String? empresaActual;
  final String? cargoActual;
  final bool habilitado;
  final bool procesoGradoCompleto;
  final bool autoevaluacionCompletada;
  final DateTime? fechaHabilitacion;
  final DateTime createdAt;

  Egresado({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.idUniversitario,
    this.carrera,
    this.telefono,
    this.ciudad,
    this.estadoLaboral,
    this.empresaActual,
    this.cargoActual,
    required this.habilitado,
    required this.procesoGradoCompleto,
    required this.autoevaluacionCompletada,
    this.fechaHabilitacion,
    required this.createdAt,
  });

  String get fullName => '$nombre $apellido';

  factory Egresado.fromJson(Map<String, dynamic> json) {
    // Handle nested carrera object
    String? carreraNombre;
    if (json['carreras'] != null) {
      if (json['carreras'] is Map) {
        carreraNombre = json['carreras']['nombre'] as String?;
      }
    } else if (json['carrera_nombre'] != null) {
      carreraNombre = json['carrera_nombre'] as String?;
    }

    return Egresado(
      id: json['id'] as String,
      correo: json['correo'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      idUniversitario: json['id_universitario'] as String?,
      carrera: carreraNombre,
      telefono: json['telefono'] as String?,
      ciudad: json['ciudad'] as String?,
      estadoLaboral: json['estado_laboral'] as String?,
      empresaActual: json['empresa_actual'] as String?,
      cargoActual: json['cargo_actual'] as String?,
      habilitado: json['habilitado'] as bool? ?? false,
      procesoGradoCompleto: json['proceso_grado_completo'] as bool? ?? false,
      autoevaluacionCompletada: json['autoevaluacion_completada'] as bool? ?? false,
      fechaHabilitacion: json['fecha_habilitacion'] != null
          ? DateTime.parse(json['fecha_habilitacion'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Dashboard Statistics Model
class DashboardStats {
  final int totalEgresados;
  final int egresadosHabilitados;
  final int documentosCompletos;
  final int autoevaluacionesCompletas;
  final List<CarreraStats> porCarrera;

  DashboardStats({
    required this.totalEgresados,
    required this.egresadosHabilitados,
    required this.documentosCompletos,
    required this.autoevaluacionesCompletas,
    required this.porCarrera,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEgresados: json['total_egresados'] as int? ?? 0,
      egresadosHabilitados: json['egresados_habilitados'] as int? ?? 0,
      documentosCompletos: json['documentos_completos'] as int? ?? 0,
      autoevaluacionesCompletas: json['autoevaluaciones_completas'] as int? ?? 0,
      porCarrera: (json['por_carrera'] as List<dynamic>?)
              ?.map((e) => CarreraStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CarreraStats {
  final String carrera;
  final int total;
  final int habilitados;
  final int documentosCompletos;
  final int autoevaluacionesCompletas;
  final int empleados;
  final int desempleados;

  CarreraStats({
    required this.carrera,
    required this.total,
    required this.habilitados,
    required this.documentosCompletos,
    required this.autoevaluacionesCompletas,
    required this.empleados,
    required this.desempleados,
  });

  factory CarreraStats.fromJson(Map<String, dynamic> json) {
    return CarreraStats(
      carrera: json['carrera'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      habilitados: json['habilitados'] as int? ?? 0,
      documentosCompletos: json['documentos_completos'] as int? ?? 0,
      autoevaluacionesCompletas: json['autoevaluaciones_completas'] as int? ?? 0,
      empleados: json['empleados'] as int? ?? 0,
      desempleados: json['desempleados'] as int? ?? 0,
    );
  }
}
