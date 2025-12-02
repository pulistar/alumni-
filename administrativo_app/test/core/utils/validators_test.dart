import 'package:flutter_test/flutter_test.dart';
import 'package:administrativo_app/core/utils/validators.dart';

void main() {
  group('Validators Test', () {
    group('validateEmail', () {
      test('returns error when email is null', () {
        expect(Validators.validateEmail(null), 'El correo electrónico es requerido');
      });

      test('returns error when email is empty', () {
        expect(Validators.validateEmail(''), 'El correo electrónico es requerido');
      });

      test('returns error when email format is invalid', () {
        expect(Validators.validateEmail('invalid-email'), 'El correo electrónico no es válido');
        expect(Validators.validateEmail('test@'), 'El correo electrónico no es válido');
        expect(Validators.validateEmail('@campusucc.edu.co'), 'El correo electrónico no es válido');
      });

      test('returns error when email domain is not institutional', () {
        expect(
          Validators.validateEmail('test@gmail.com'),
          'Solo se permiten correos institucionales @campusucc.edu.co',
        );
        expect(
          Validators.validateEmail('admin@example.com'),
          'Solo se permiten correos institucionales @campusucc.edu.co',
        );
      });

      test('returns null when email is valid institutional email', () {
        expect(Validators.validateEmail('admin@campusucc.edu.co'), null);
        expect(Validators.validateEmail('test.user@campusucc.edu.co'), null);
      });
    });

    group('validatePassword', () {
      test('returns error when password is null', () {
        expect(Validators.validatePassword(null), 'La contraseña es requerida');
      });

      test('returns error when password is empty', () {
        expect(Validators.validatePassword(''), 'La contraseña es requerida');
      });

      test('returns error when password is too short', () {
        expect(
          Validators.validatePassword('12345'),
          'La contraseña debe tener al menos 6 caracteres',
        );
        expect(
          Validators.validatePassword('abc'),
          'La contraseña debe tener al menos 6 caracteres',
        );
      });

      test('returns null when password is valid', () {
        expect(Validators.validatePassword('123456'), null);
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('MySecureP@ssw0rd!'), null);
      });
    });
  });
}
