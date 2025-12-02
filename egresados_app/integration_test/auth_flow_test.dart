import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:egresados_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Test', () {
    testWidgets('Complete authentication flow from login to home',
        (WidgetTester tester) async {
      // Iniciar la app
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que cargue el onboarding
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que estamos en el onboarding
      expect(find.text('Bienvenido'), findsWidgets);

      // Navegar por el onboarding (si está presente)
      // Buscar botón de "Siguiente" o "Comenzar"
      final nextButton = find.text('Siguiente');
      if (nextButton.evaluate().isNotEmpty) {
        // Hacer swipe o tap en siguiente hasta llegar al final
        for (int i = 0; i < 3; i++) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
        }

        // Tap en "Comenzar"
        final startButton = find.text('Comenzar');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton);
          await tester.pumpAndSettle();
        }
      }

      // Ahora deberíamos estar en LoginScreen
      expect(find.text('Alumni UCC'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);

      // Ingresar email institucional
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@campusucc.edu.co');
      await tester.pumpAndSettle();

      // Tap en continuar
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Deberíamos estar en MagicLinkScreen
      expect(find.text('¡Revisa tu correo!'), findsOneWidget);
      expect(find.text('test@campusucc.edu.co'), findsOneWidget);

      // Verificar que se muestran las instrucciones
      expect(find.text('Abre el correo que te enviamos'), findsOneWidget);
      expect(find.text('Haz clic en el enlace mágico'), findsOneWidget);

      // Verificar botón de reenviar
      expect(find.text('No recibí el correo, reenviar'), findsOneWidget);
    });

    testWidgets('Validation errors are shown correctly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que cargue
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navegar al login (saltar onboarding si está presente)
      final skipButton = find.text('Saltar');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Intentar enviar sin email
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verificar error de validación
      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);

      // Ingresar email inválido
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verificar error de formato
      expect(find.text('Ingresa un correo válido'), findsOneWidget);
    });

    testWidgets('Help dialog can be opened and closed',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Esperar y navegar al login
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final skipButton = find.text('Saltar');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Abrir diálogo de ayuda
      final helpButton = find.text('¿Necesitas ayuda?');
      await tester.tap(helpButton);
      await tester.pumpAndSettle();

      // Verificar que se abrió el diálogo
      expect(find.byType(AlertDialog), findsOneWidget);

      // Cerrar el diálogo
      final closeButton = find.text('Cerrar');
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
      }

      // Verificar que se cerró
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
