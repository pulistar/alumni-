import 'package:flutter_test/flutter_test.dart';
import 'package:egresados_app/data/models/user_model.dart';

void main() {
  group('EgresadoModel Tests', () {
    test('should create EgresadoModel from JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'uid': 'user-123',
        'correo_institucional': 'juan@ucc.edu.co',
        'nombre': 'Juan',
        'apellido': 'Pérez',
        'id_universitario': '2020123456',
        'carrera_id': 'carrera-1',
        'celular': '3001234567',
        'correo_personal': 'juan@gmail.com',
        'tipo_documento_id': 'tipo-1',
        'documento': '1234567890',
        'lugar_expedicion': 'Cali',
        'grado_academico_id': 'grado-1',
        'habilitado': true,
        'proceso_grado_completo': false,
        'autoevaluacion_habilitada': true,
        'autoevaluacion_completada': false,
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final egresado = EgresadoModel.fromJson(json);

      // Assert
      expect(egresado.id, '123');
      expect(egresado.uid, 'user-123');
      expect(egresado.nombre, 'Juan');
      expect(egresado.apellido, 'Pérez');
      expect(egresado.correoInstitucional, 'juan@ucc.edu.co');
      expect(egresado.idUniversitario, '2020123456');
      expect(egresado.habilitado, true);
    });

    test('should convert EgresadoModel to JSON', () {
      // Arrange
      final egresado = EgresadoModel(
        id: '123',
        uid: 'user-123',
        correoInstitucional: 'juan@ucc.edu.co',
        nombre: 'Juan',
        apellido: 'Pérez',
        idUniversitario: '2020123456',
        carreraId: 'carrera-1',
        celular: '3001234567',
        correoPersonal: 'juan@gmail.com',
        tipoDocumentoId: 'tipo-1',
        documento: '1234567890',
        lugarExpedicion: 'Cali',
        gradoAcademicoId: 'grado-1',
        habilitado: true,
        procesoGradoCompleto: false,
        autoevaluacionHabilitada: true,
        autoevaluacionCompletada: false,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act
      final json = egresado.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['uid'], 'user-123');
      expect(json['nombre'], 'Juan');
      expect(json['apellido'], 'Pérez');
      expect(json['correo_institucional'], 'juan@ucc.edu.co');
      expect(json['id_universitario'], '2020123456');
    });

    test('should handle optional fields correctly', () {
      // Arrange
      final json = {
        'id': '123',
        'uid': 'user-123',
        'correo_institucional': 'juan@ucc.edu.co',
        'nombre': 'Juan',
        'apellido': 'Pérez',
        'id_universitario': '2020123456',
        'carrera_id': 'carrera-1',
        'celular': '3001234567',
        'telefono_alternativo': null,
        'correo_personal': 'juan@gmail.com',
        'tipo_documento_id': 'tipo-1',
        'documento': '1234567890',
        'lugar_expedicion': 'Cali',
        'grado_academico_id': 'grado-1',
        'created_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final egresado = EgresadoModel.fromJson(json);

      // Assert
      expect(egresado.id, '123');
      expect(egresado.telefonoAlternativo, isNull);
      expect(egresado.updatedAt, isNull);
    });

    test('should get full name correctly', () {
      // Arrange
      final egresado = EgresadoModel(
        id: '123',
        uid: 'user-123',
        correoInstitucional: 'juan@ucc.edu.co',
        nombre: 'Juan Carlos',
        apellido: 'Pérez López',
        idUniversitario: '2020123456',
        carreraId: 'carrera-1',
        celular: '3001234567',
        correoPersonal: 'juan@gmail.com',
        tipoDocumentoId: 'tipo-1',
        documento: '1234567890',
        lugarExpedicion: 'Cali',
        gradoAcademicoId: 'grado-1',
        habilitado: true,
        procesoGradoCompleto: false,
        autoevaluacionHabilitada: true,
        autoevaluacionCompletada: false,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      // Act
      final fullName = egresado.nombreCompleto;

      // Assert
      expect(fullName, 'Juan Carlos Pérez López');
    });
  });
}
