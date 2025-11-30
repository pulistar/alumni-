/// Validators for form inputs
class Validators {
  /// Validates email format and domain
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'El correo electrónico no es válido';
    }
    
    // Check for institutional domain
    if (!value.endsWith('@campusucc.edu.co')) {
      return 'Solo se permiten correos institucionales @campusucc.edu.co';
    }
    
    return null;
  }
  
  /// Validates password length
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
}
