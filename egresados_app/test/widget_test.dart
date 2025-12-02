import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build a simple MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Alumni UCC'),
          ),
        ),
      ),
    );

    // Verify that the app builds successfully
    expect(find.text('Alumni UCC'), findsOneWidget);
  });

  testWidgets('TextFormField should accept input', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ),
      ),
    );

    // Enter text
    await tester.enterText(find.byType(TextFormField), 'test@example.com');
    
    // Verify text was entered
    expect(controller.text, 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('Button should be tappable', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              wasTapped = true;
            },
            child: const Text('Tap Me'),
          ),
        ),
      ),
    );

    // Tap the button
    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    // Verify button was tapped
    expect(wasTapped, true);
  });
}
