import 'package:flutter_test/flutter_test.dart';
import 'package:egresados_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@gmail.com'), isNull);
        expect(Validators.email('user@example.com'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('invalid@'), isNotNull);
        expect(Validators.email('@example.com'), isNotNull);
      });
    });

    group('institutionalEmail', () {
      test('returns null for valid institutional email', () {
        expect(Validators.institutionalEmail('test@campusucc.edu.co'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.institutionalEmail(''), isNotNull);
        expect(Validators.institutionalEmail(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.institutionalEmail('invalid'), isNotNull);
        expect(Validators.institutionalEmail('invalid@'), isNotNull);
      });

      test('returns error for non-institutional email', () {
        expect(Validators.institutionalEmail('test@gmail.com'), isNotNull);
        expect(Validators.institutionalEmail('test@hotmail.com'), isNotNull);
      });

      test('is case insensitive', () {
        expect(Validators.institutionalEmail('TEST@CAMPUSUCC.EDU.CO'), isNull);
        expect(Validators.institutionalEmail('Test@CampusUCC.Edu.Co'), isNull);
      });
    });

    group('colombianPhone', () {
      test('returns null for valid 10-digit phone', () {
        expect(Validators.colombianPhone('3001234567'), isNull);
        expect(Validators.colombianPhone('3101234567'), isNull);
        expect(Validators.colombianPhone('3201234567'), isNull);
      });

      test('returns null for optional empty phone', () {
        expect(Validators.colombianPhone('', required: false), isNull);
        expect(Validators.colombianPhone(null, required: false), isNull);
      });

      test('returns error for required empty phone', () {
        expect(Validators.colombianPhone(''), isNotNull);
        expect(Validators.colombianPhone(null), isNotNull);
      });

      test('returns error for invalid length', () {
        expect(Validators.colombianPhone('123'), isNotNull);
        expect(Validators.colombianPhone('12345678901'), isNotNull);
      });

      test('returns error for non-numeric characters', () {
        expect(Validators.colombianPhone('300-123-4567'), isNotNull);
        expect(Validators.colombianPhone('300 123 4567'), isNotNull);
        expect(Validators.colombianPhone('abc1234567'), isNotNull);
      });
    });

    group('required', () {
      test('returns null for non-empty value', () {
        expect(Validators.required('test', 'Field'), isNull);
        expect(Validators.required('   test   ', 'Field'), isNull);
      });

      test('returns error for empty value', () {
        expect(Validators.required('', 'Field'), isNotNull);
        expect(Validators.required(null, 'Field'), isNotNull);
        expect(Validators.required('   ', 'Field'), isNotNull);
      });

      test('includes field name in error message', () {
        final error = Validators.required('', 'Email');
        expect(error, contains('Email'));
      });
    });

    group('fullName', () {
      test('returns null for valid full name with capitalization', () {
        expect(Validators.fullName('Juan Pérez', 'Name'), isNull);
        expect(Validators.fullName('María José García', 'Name'), isNull);
      });

      test('returns error for empty name', () {
        expect(Validators.fullName('', 'Name'), isNotNull);
        expect(Validators.fullName(null, 'Name'), isNotNull);
      });

      test('returns error for too short name', () {
        expect(Validators.fullName('A', 'Name'), isNotNull);
      });

      test('returns error for names not starting with capital letter', () {
        expect(Validators.fullName('juan pérez', 'Name'), isNotNull);
        expect(Validators.fullName('Juan pérez', 'Name'), isNotNull);
      });

      test('accepts properly capitalized names', () {
        expect(Validators.fullName('José María', 'Name'), isNull);
        expect(Validators.fullName('Ángel García', 'Name'), isNull);
      });
    });

    group('universityId', () {
      test('returns null for valid 6-digit ID', () {
        expect(Validators.universityId('123456'), isNull);
        expect(Validators.universityId('000000'), isNull);
        expect(Validators.universityId('999999'), isNull);
      });

      test('returns error for empty ID', () {
        expect(Validators.universityId(''), isNotNull);
        expect(Validators.universityId(null), isNotNull);
      });

      test('returns error for invalid length', () {
        expect(Validators.universityId('12345'), isNotNull);
        expect(Validators.universityId('1234567'), isNotNull);
      });

      test('returns error for non-numeric ID', () {
        expect(Validators.universityId('12345a'), isNotNull);
        expect(Validators.universityId('abc123'), isNotNull);
      });
    });

    group('minLength', () {
      test('returns null when value meets minimum length', () {
        expect(Validators.minLength('test', 3, 'Field'), isNull);
        expect(Validators.minLength('test', 4, 'Field'), isNull);
      });

      test('returns error when value is too short', () {
        expect(Validators.minLength('ab', 3, 'Field'), isNotNull);
      });

      test('returns null for empty values', () {
        expect(Validators.minLength(null, 3, 'Field'), isNull);
        expect(Validators.minLength('', 3, 'Field'), isNull);
      });
    });

    group('maxLength', () {
      test('returns null when value is within maximum length', () {
        expect(Validators.maxLength('test', 5, 'Field'), isNull);
        expect(Validators.maxLength('test', 4, 'Field'), isNull);
      });

      test('returns error when value is too long', () {
        expect(Validators.maxLength('testing', 5, 'Field'), isNotNull);
      });

      test('returns null for empty values', () {
        expect(Validators.maxLength(null, 5, 'Field'), isNull);
        expect(Validators.maxLength('', 5, 'Field'), isNull);
      });
    });

    group('name', () {
      test('returns null for valid name', () {
        expect(Validators.name('Juan'), isNull);
        expect(Validators.name('María José'), isNull);
      });

      test('returns error for empty name', () {
        expect(Validators.name(''), isNotNull);
        expect(Validators.name(null), isNotNull);
      });

      test('returns error for too short name', () {
        expect(Validators.name('A'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid phone', () {
        expect(Validators.phone('1234567'), isNull);
        expect(Validators.phone('123-456-7890'), isNull);
        expect(Validators.phone('+57 300 1234567'), isNull);
      });

      test('returns null for empty phone (optional)', () {
        expect(Validators.phone(''), isNull);
        expect(Validators.phone(null), isNull);
      });

      test('returns error for invalid phone format', () {
        expect(Validators.phone('abc'), isNotNull);
        expect(Validators.phone('12'), isNotNull);
      });
    });

    group('capitalizeWords', () {
      test('capitalizes first letter of each word', () {
        expect(Validators.capitalizeWords('juan pérez'), equals('Juan Pérez'));
        expect(Validators.capitalizeWords('MARÍA JOSÉ'), equals('María José'));
      });

      test('handles empty string', () {
        expect(Validators.capitalizeWords(''), equals(''));
      });

      test('handles single word', () {
        expect(Validators.capitalizeWords('test'), equals('Test'));
      });
    });

    group('Edge Cases', () {
      test('handles whitespace-only strings', () {
        expect(Validators.required('   ', 'Field'), isNotNull);
        expect(Validators.fullName('   ', 'Name'), isNotNull);
      });

      test('handles very long inputs', () {
        final longString = 'a' * 1000;
        expect(Validators.maxLength(longString, 999, 'Field'), isNotNull);
        expect(Validators.maxLength(longString, 1001, 'Field'), isNull);
      });

      test('handles trimming correctly', () {
        expect(Validators.required('  test  ', 'Field'), isNull);
        expect(Validators.universityId('  123456  '), isNull);
        expect(Validators.colombianPhone('  3001234567  '), isNull);
      });
    });
  });
}
