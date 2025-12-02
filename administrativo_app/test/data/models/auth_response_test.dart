import 'package:flutter_test/flutter_test.dart';
import 'package:administrativo_app/data/models/auth_response.dart';
import 'package:administrativo_app/data/models/user.dart';

void main() {
  group('AuthResponse Model Test', () {
    final userJson = {
      'id': '123',
      'email': 'test@example.com',
      'role': 'admin',
      'nombre': 'Test',
      'apellido': 'User',
    };

    final authResponseJson = {
      'accessToken': 'token123',
      'user': userJson,
    };

    test('fromJson creates a valid AuthResponse instance', () {
      final authResponse = AuthResponse.fromJson(authResponseJson);

      expect(authResponse.accessToken, 'token123');
      expect(authResponse.user.id, '123');
      expect(authResponse.user.email, 'test@example.com');
    });

    test('toJson returns a valid map', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        role: 'admin',
        nombre: 'Test',
        apellido: 'User',
      );

      final authResponse = AuthResponse(
        accessToken: 'token123',
        user: user,
      );

      final json = authResponse.toJson();

      expect(json['accessToken'], 'token123');
      expect(json['user'], userJson);
    });
  });
}
