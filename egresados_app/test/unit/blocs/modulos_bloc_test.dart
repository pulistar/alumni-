import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:egresados_app/presentation/blocs/modulos/modulos_bloc.dart';
import 'package:egresados_app/presentation/blocs/modulos/modulos_event.dart';
import 'package:egresados_app/presentation/blocs/modulos/modulos_state.dart';
import 'package:egresados_app/data/services/modulos_service.dart';
import 'package:egresados_app/data/models/modulo.dart';

// Mock del ModulosService
class MockModulosService extends Mock implements ModulosService {}

void main() {
  group('ModulosBloc', () {
    late ModulosBloc modulosBloc;
    late MockModulosService mockModulosService;

    setUp(() {
      mockModulosService = MockModulosService();
      modulosBloc = ModulosBloc(modulosService: mockModulosService);
    });

    tearDown(() {
      modulosBloc.close();
    });

    test('initial state is ModulosInitial', () {
      expect(modulosBloc.state, equals(ModulosInitial()));
    });

    group('ModulosLoadRequested', () {
      final mockModulos = [
        Modulo(
          id: '1',
          nombre: 'PreAlumni',
          descripcion: 'Módulo de egresados',
          icono: 'school',
          activo: true,
          orden: 1,
        ),
        Modulo(
          id: '2',
          nombre: 'Documentos',
          descripcion: 'Gestión de documentos',
          icono: 'folder',
          activo: true,
          orden: 2,
        ),
      ];

      blocTest<ModulosBloc, ModulosState>(
        'emits [ModulosLoading, ModulosLoaded] when modules are loaded successfully',
        build: () {
          when(() => mockModulosService.getModulos())
              .thenAnswer((_) async => mockModulos);
          return modulosBloc;
        },
        act: (bloc) => bloc.add(ModulosLoadRequested()),
        expect: () => [
          ModulosLoading(),
          isA<ModulosLoaded>()
              .having((state) => state.modulosActivos.length, 'active modules count', 2),
        ],
        verify: (_) {
          verify(() => mockModulosService.getModulos()).called(1);
        },
      );

      blocTest<ModulosBloc, ModulosState>(
        'emits [ModulosLoading, ModulosError] when loading fails',
        build: () {
          when(() => mockModulosService.getModulos())
              .thenThrow(Exception('Network error'));
          return modulosBloc;
        },
        act: (bloc) => bloc.add(ModulosLoadRequested()),
        expect: () => [
          ModulosLoading(),
          isA<ModulosError>(),
        ],
      );

      blocTest<ModulosBloc, ModulosState>(
        'filters out inactive modules',
        build: () {
          final modulosWithInactive = [
            ...mockModulos,
            Modulo(
              id: '3',
              nombre: 'Inactivo',
              descripcion: 'Módulo inactivo',
              icono: 'block',
              activo: false,
              orden: 3,
            ),
          ];
          when(() => mockModulosService.getModulos())
              .thenAnswer((_) async => modulosWithInactive);
          return modulosBloc;
        },
        act: (bloc) => bloc.add(ModulosLoadRequested()),
        expect: () => [
          ModulosLoading(),
          isA<ModulosLoaded>()
              .having(
                (state) => state.modulosActivos.length,
                'only active modules',
                2,
              ),
        ],
      );
    });

    group('ModulosRefreshRequested', () {
      final mockModulos = [
        Modulo(
          id: '1',
          nombre: 'PreAlumni',
          descripcion: 'Módulo de egresados',
          icono: 'school',
          activo: true,
          orden: 1,
        ),
      ];

      blocTest<ModulosBloc, ModulosState>(
        'refreshes modules successfully',
        build: () {
          when(() => mockModulosService.getModulos())
              .thenAnswer((_) async => mockModulos);
          return modulosBloc;
        },
        act: (bloc) => bloc.add(ModulosRefreshRequested()),
        expect: () => [
          ModulosLoading(),
          isA<ModulosLoaded>(),
        ],
      );
    });
  });
}
