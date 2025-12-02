import 'package:flutter_test/flutter_test.dart';
import 'package:administrativo_app/data/models/login_request.dart';

void main() {
  group('LoginRequest Model Test', () {
    test('toJson returns correct map', () {
      final loginRequest = LoginRequest(
        email: 'admin@campusucc.edu.co',
        password: 'password123',
      );

      final json = loginRequest.toJson();

      expect(json['email'], 'admin@campusucc.edu.co');
      expect(json['password'], 'password123');
    });

    test('creates instance with required fields', () {
      final loginRequest = LoginRequest(
        email: 'test@campusucc.edu.co',
        password: 'testpass',
      );

      expect(loginRequest.email, 'test@campusucc.edu.co');
      expect(loginRequest.password, 'testpass');
    });
  });
}
