import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:egresados_app/presentation/screens/auth/login_screen.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_state.dart';
import 'package:egresados_app/presentation/blocs/auth/auth_event.dart';
import 'package:egresados_app/data/services/auth_service.dart';

// Mock classes
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockAuthService extends Mock implements AuthService {}

// Fake classes for fallback values
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeAuthState extends Fake implements AuthState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  group('LoginScreen Widget Tests', () {
    late MockAuthBloc mockAuthBloc;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      mockAuthService = MockAuthService();
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthUnauthenticated()));
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('renders LoginScreen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar que se muestra el título
      expect(find.text('Alumni UCC'), findsOneWidget);
      expect(find.text('Portal de Egresados'), findsOneWidget);

      // Verificar que se muestra el formulario
      expect(find.text('Iniciar Sesión'), findsOneWidget);

      // Verificar que se muestra el botón
      expect(find.text('Continuar'), findsOneWidget);

      // Verificar que se muestra el icono de la universidad
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    });

    testWidgets('shows validation error for empty email',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontrar y tocar el botón sin ingresar email
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verificar que se muestra el error de validación
      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ingresar email inválido
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      // Tocar el botón
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verificar que se muestra el error de validación
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
    });

    testWidgets('accepts valid email and navigates',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ingresar email válido
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@campusucc.edu.co');
      await tester.pumpAndSettle();

      // Tocar el botón
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verificar que se agregó el evento al bloc
      verify(() => mockAuthBloc.add(any(that: isA<AuthMagicLinkRequested>()))).called(1);
    });

    testWidgets('email field accepts keyboard input',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField);

      // Ingresar texto
      await tester.enterText(emailField, 'test@campusucc.edu.co');
      await tester.pumpAndSettle();

      // Verificar que el texto se ingresó correctamente
      expect(find.text('test@campusucc.edu.co'), findsOneWidget);
    });

    testWidgets('help button is visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar que se muestra el botón de ayuda
      expect(find.text('¿Necesitas ayuda?'), findsOneWidget);
    });

    testWidgets('terms and privacy buttons are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar que se muestran los botones de términos y privacidad
      expect(find.text('Términos'), findsOneWidget);
      expect(find.text('Privacidad'), findsOneWidget);
    });
  });
}
