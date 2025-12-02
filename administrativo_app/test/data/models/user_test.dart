import 'package:flutter_test/flutter_test.dart';
import 'package:administrativo_app/data/models/user.dart';

void main() {
  group('User Model Test', () {
    final userJson = {
      'id': '123',
      'email': 'test@example.com',
      'role': 'admin',
      'nombre': 'Test',
      'apellido': 'User',
    };

    test('fromJson creates a valid User instance', () {
      final user = User.fromJson(userJson);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.role, 'admin');
      expect(user.nombre, 'Test');
      expect(user.apellido, 'User');
    });

    test('toJson returns a valid map', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        role: 'admin',
        nombre: 'Test',
        apellido: 'User',
      );

      final json = user.toJson();

      expect(json, userJson);
    });

    test('fullName returns correct full name', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        role: 'admin',
        nombre: 'Test',
        apellido: 'User',
      );

      expect(user.fullName, 'Test User');
    });

    test('fullName returns email if name is missing', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        role: 'admin',
      );

      expect(user.fullName, 'test@example.com');
    });
  });
}
