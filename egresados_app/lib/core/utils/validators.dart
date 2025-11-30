// Validadores para formularios
class Validators {
  // Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    return null;
  }

  // Validar email institucional UCC
  static String? institutionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    // Primero validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    
    // Validar dominio institucional
    if (!value.toLowerCase().endsWith('@campusucc.edu.co')) {
      return 'Solo se permiten correos institucionales @campusucc.edu.co';
    }
    
    return null;
  }
  
  // Validar campo requerido
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }
  
  // Validar nombre
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }
  
  // Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }
    
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }
    
    return null;
  }
  
  // Validar longitud mínima
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    
    return null;
  }
  
  // Validar longitud máxima
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }
    
    return null;
  }

  // Validar nombre completo con primera letra en mayúscula
  static String? fullName(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final trimmedValue = value.trim();
    
    // Validar que tenga al menos 2 caracteres
    if (trimmedValue.length < 2) {
      return '${fieldName ?? 'Este campo'} debe tener al menos 2 caracteres';
    }

    // Validar que cada palabra empiece con mayúscula
    final words = trimmedValue.split(' ');
    for (var word in words) {
      if (word.isNotEmpty && word[0] != word[0].toUpperCase()) {
        return 'Cada palabra debe empezar con mayúscula';
      }
    }

    return null;
  }

  // Validar ID universitario (exactamente 6 dígitos)
  static String? universityId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El ID universitario es requerido';
    }

    final trimmedValue = value.trim();
    
    // Validar que solo contenga dígitos
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
      return 'El ID debe contener solo números';
    }

    // Validar que tenga exactamente 6 dígitos
    if (trimmedValue.length != 6) {
      return 'El ID debe tener exactamente 6 dígitos';
    }

    return null;
  }

  // Validar teléfono colombiano (exactamente 10 dígitos)
  static String? colombianPhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El teléfono es requerido' : null;
    }

    final trimmedValue = value.trim();
    
    // Validar que solo contenga dígitos
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
      return 'El teléfono debe contener solo números';
    }

    // Validar que tenga exactamente 10 dígitos
    if (trimmedValue.length != 10) {
      return 'El teléfono debe tener exactamente 10 dígitos';
    }

    return null;
  }

  // Capitalizar primera letra de cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
