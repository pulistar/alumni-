import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_event.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_state.dart';
import 'package:egresados_app/data/services/auth_service.dart';
import 'package:egresados_app/data/models/user_model.dart';

// Mock del AuthService
class MockAuthService extends Mock implements AuthService {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(AuthInitialized());
    registerFallbackValue(AuthMagicLinkRequested(email: ''));
  });

  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AuthInitialized', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no session exists',
        build: () {
          when(() => mockAuthService.getCurrentUser())
              .thenAnswer((_) async => null);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthInitialized()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthService.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthenticatedWithProfile] when user has complete profile',
        build: () {
          final mockUser = UserModel(
            id: '123',
            email: 'test@campusucc.edu.co',
            nombreCompleto: 'Test User',
            nombre: 'Test',
            apellido: 'User',
            celular: '3001234567',
            correoPersonal: 'test@gmail.com',
            documento: '123456789',
            tipoDocumentoId: '1',
            gradoAcademicoId: '1',
            carreraId: '1',
            idUniversitario: '123456',
            habilitado: true,
            createdAt: DateTime.now(),
          );
          when(() => mockAuthService.getCurrentUser())
              .thenAnswer((_) async => mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthInitialized()),
        expect: () => [
          AuthLoading(),
          isA<AuthenticatedWithProfile>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthenticatedWithoutProfile] when user has incomplete profile',
        build: () {
          when(() => mockAuthService.getCurrentUser())
              .thenAnswer((_) async => throw Exception('Profile incomplete'));
          when(() => mockAuthService.hasSession())
              .thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthInitialized()),
        expect: () => [
          AuthLoading(),
          AuthenticatedWithoutProfile(),
        ],
      );
    });

    group('AuthMagicLinkRequested', () {
      const testEmail = 'test@campusucc.edu.co';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthMagicLinkSent] when magic link is sent successfully',
        build: () {
          when(() => mockAuthService.sendMagicLink(testEmail))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthMagicLinkRequested(email: testEmail)),
        expect: () => [
          AuthLoading(),
          AuthMagicLinkSent(email: testEmail),
        ],
        verify: (_) {
          verify(() => mockAuthService.sendMagicLink(testEmail)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when magic link fails',
        build: () {
          when(() => mockAuthService.sendMagicLink(testEmail))
              .thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthMagicLinkRequested(email: testEmail)),
        expect: () => [
          AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthProfileCompleted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthCompletingProfile, AuthenticatedWithProfile] when profile is completed successfully',
        build: () {
          final mockUser = UserModel(
            id: '123',
            email: 'test@campusucc.edu.co',
            nombreCompleto: 'Test User',
            nombre: 'Test',
            apellido: 'User',
            celular: '3001234567',
            correoPersonal: 'test@gmail.com',
            documento: '123456789',
            tipoDocumentoId: '1',
            gradoAcademicoId: '1',
            carreraId: '1',
            idUniversitario: '123456',
            habilitado: true,
            createdAt: DateTime.now(),
          );
          when(() => mockAuthService.completeProfile(
                nombre: any(named: 'nombre'),
                apellido: any(named: 'apellido'),
                celular: any(named: 'celular'),
                telefonoAlternativo: any(named: 'telefonoAlternativo'),
                correoPersonal: any(named: 'correoPersonal'),
                tipoDocumentoId: any(named: 'tipoDocumentoId'),
                documento: any(named: 'documento'),
                lugarExpedicion: any(named: 'lugarExpedicion'),
                gradoAcademicoId: any(named: 'gradoAcademicoId'),
                carreraId: any(named: 'carreraId'),
                idUniversitario: any(named: 'idUniversitario'),
              )).thenAnswer((_) async => mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileCompleted(
          nombre: 'Test',
          apellido: 'User',
          celular: '3001234567',
          correoPersonal: 'test@gmail.com',
          tipoDocumentoId: '1',
          documento: '123456789',
          lugarExpedicion: 'Bogotá',
          gradoAcademicoId: '1',
          carreraId: '1',
          idUniversitario: '123456',
        )),
        expect: () => [
          AuthCompletingProfile(),
          isA<AuthenticatedWithProfile>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthCompletingProfile, AuthProfileCompletionFailure] when profile completion fails',
        build: () {
          when(() => mockAuthService.completeProfile(
                nombre: any(named: 'nombre'),
                apellido: any(named: 'apellido'),
                celular: any(named: 'celular'),
                telefonoAlternativo: any(named: 'telefonoAlternativo'),
                correoPersonal: any(named: 'correoPersonal'),
                tipoDocumentoId: any(named: 'tipoDocumentoId'),
                documento: any(named: 'documento'),
                lugarExpedicion: any(named: 'lugarExpedicion'),
                gradoAcademicoId: any(named: 'gradoAcademicoId'),
                carreraId: any(named: 'carreraId'),
                idUniversitario: any(named: 'idUniversitario'),
              )).thenThrow(Exception('Validation error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileCompleted(
          nombre: 'Test',
          apellido: 'User',
          celular: '3001234567',
          correoPersonal: 'test@gmail.com',
          tipoDocumentoId: '1',
          documento: '123456789',
          lugarExpedicion: 'Bogotá',
          gradoAcademicoId: '1',
          carreraId: '1',
          idUniversitario: '123456',
        )),
        expect: () => [
          AuthCompletingProfile(),
          isA<AuthProfileCompletionFailure>(),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when sign out is successful',
        build: () {
          when(() => mockAuthService.signOut())
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthSignOutRequested()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockAuthService.signOut()).called(1);
        },
      );
    });

    group('AuthProfileRefreshRequested', () {
      blocTest<AuthBloc, AuthState>(
        'refreshes user profile successfully',
        build: () {
          final mockUser = UserModel(
            id: '123',
            email: 'test@campusucc.edu.co',
            nombreCompleto: 'Test User Updated',
            nombre: 'Test',
            apellido: 'User',
            celular: '3001234567',
            correoPersonal: 'test@gmail.com',
            documento: '123456789',
            tipoDocumentoId: '1',
            gradoAcademicoId: '1',
            carreraId: '1',
            idUniversitario: '123456',
            habilitado: true,
            createdAt: DateTime.now(),
          );
          when(() => mockAuthService.getCurrentUser())
              .thenAnswer((_) async => mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthProfileRefreshRequested()),
        expect: () => [
          isA<AuthenticatedWithProfile>(),
        ],
      );
    });
  });
}
