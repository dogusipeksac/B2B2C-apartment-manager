bool _isDigits(String input) => RegExp(r'^\d+$').hasMatch(input);

String _onlyDigits(String input) => input.replaceAll(RegExp('[^0-9]'), '');

String? validateRequired(String? value, {required String message}) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

String? validateMinLength(
  String? value, {
  required int minLength,
  required String message,
}) {
  if (value == null) {
    return message;
  }
  return value.trim().length < minLength ? message : null;
}

String? validateEmail(String? value, {required String message}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final email = value.trim();
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return regex.hasMatch(email) ? null : message;
}

String? validatePhone(String? value, {required String message}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  var digits = _onlyDigits(value);
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.startsWith('90') && digits.length >= 12) {
    digits = digits.substring(2);
  }

  if (digits.length != 10) {
    return message;
  }
  if (!digits.startsWith('5')) {
    return message;
  }
  return _isDigits(digits) ? null : message;
}

String? validateTcKimlik(String? value, {required String message}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final v = _onlyDigits(value);
  if (v.length != 11 || !_isDigits(v)) {
    return message;
  }
  if (v[0] == '0') {
    return message;
  }

  final digits = v.split('').map(int.parse).toList(growable: false);

  final oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
  final evenSum = digits[1] + digits[3] + digits[5] + digits[7];

  final tenth = ((oddSum * 7) - evenSum) % 10;
  if (digits[9] != tenth) {
    return message;
  }

  final firstTenSum = digits.take(10).reduce((a, b) => a + b);
  final eleventh = firstTenSum % 10;
  if (digits[10] != eleventh) {
    return message;
  }

  return null;
}

String? validateIban(String? value, {required String message}) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final iban = value.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  if (!iban.startsWith('TR') || iban.length != 26) {
    return message;
  }

  final rearranged = iban.substring(4) + iban.substring(0, 4);
  final numeric = StringBuffer();

  for (final ch in rearranged.split('')) {
    final code = ch.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      numeric.write(ch);
    } else if (code >= 65 && code <= 90) {
      numeric.write(code - 55);
    } else {
      return message;
    }
  }

  var remainder = 0;
  for (final ch in numeric.toString().split('')) {
    remainder = (remainder * 10 + int.parse(ch)) % 97;
  }

  return remainder == 1 ? null : message;
}
