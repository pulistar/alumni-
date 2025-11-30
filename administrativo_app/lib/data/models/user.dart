/// User Model
/// Represents an authenticated admin user
class User {
  final String id;
  final String email;
  final String role;
  final String? nombre;
  final String? apellido;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.nombre,
    this.apellido,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      nombre: json['nombre'] as String?,
      apellido: json['apellido'] as String?,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'nombre': nombre,
      'apellido': apellido,
    };
  }

  /// Get full name
  String get fullName {
    if (nombre != null && apellido != null) {
      return '$nombre $apellido';
    } else if (nombre != null) {
      return nombre!;
    } else if (apellido != null) {
      return apellido!;
    }
    return email;
  }
}
