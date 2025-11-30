import 'package:flutter/services.dart';

/// Formatter que capitaliza la primera letra de cada palabra
class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalizar la primera letra de cada palabra
    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    final capitalizedText = capitalizedWords.join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: newValue.selection,
    );
  }
}

/// Formatter que solo permite dígitos y limita la longitud
class DigitsOnlyFormatter extends TextInputFormatter {
  final int maxLength;

  DigitsOnlyFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo permitir dígitos
    final filteredText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limitar longitud
    final limitedText = filteredText.length > maxLength
        ? filteredText.substring(0, maxLength)
        : filteredText;

    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}
