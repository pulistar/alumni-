import 'package:flutter_test/flutter_test.dart';
import 'package:egresados_app/data/services/documentos_service.dart';

void main() {
  group('TipoDocumento Enum Tests', () {
    test('should have all required document types', () {
      // Assert
      expect(TipoDocumento.values.length, 5);
      expect(TipoDocumento.values, contains(TipoDocumento.momentoOle));
      expect(TipoDocumento.values, contains(TipoDocumento.datosEgresados));
      expect(TipoDocumento.values, contains(TipoDocumento.bolsaEmpleo));
      expect(TipoDocumento.values, contains(TipoDocumento.unificado));
      expect(TipoDocumento.values, contains(TipoDocumento.otro));
    });

    test('should have correct display names', () {
      // Assert
      expect(TipoDocumento.momentoOle.displayName, 'Momento OLE');
      expect(TipoDocumento.datosEgresados.displayName, 'Datos de Egresados');
      expect(TipoDocumento.bolsaEmpleo.displayName, 'Bolsa de Empleo');
      expect(TipoDocumento.unificado.displayName, 'PDF Unificado');
      expect(TipoDocumento.otro.displayName, 'Otro');
    });

    test('should have correct values for API', () {
      // Assert
      expect(TipoDocumento.momentoOle.value, 'momento_ole');
      expect(TipoDocumento.datosEgresados.value, 'datos_egresados');
      expect(TipoDocumento.bolsaEmpleo.value, 'bolsa_empleo');
      expect(TipoDocumento.unificado.value, 'unificado');
      expect(TipoDocumento.otro.value, 'otro');
    });
  });
}
