import 'package:intl/intl.dart';

String formatTL(num amount) {
  final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  return formatter.format(amount);
}

String formatDate(DateTime dateTime) {
  final formatter = DateFormat.yMMMMd('tr_TR');
  return formatter.format(dateTime);
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('d MMMM y, HH:mm', 'tr_TR');
  return formatter.format(dateTime);
}

String formatPhone(String input) {
  var digits = input.replaceAll(RegExp('[^0-9]'), '');
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.startsWith('90') && digits.length >= 12) {
    digits = digits.substring(2);
  }

  if (digits.length != 10) {
    return input;
  }

  final p1 = digits.substring(0, 3);
  final p2 = digits.substring(3, 6);
  final p3 = digits.substring(6, 8);
  final p4 = digits.substring(8, 10);
  return '+90 $p1 $p2 $p3 $p4';
}

String formatIban(String input) {
  final normalized = input.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  final buffer = StringBuffer();
  for (var i = 0; i < normalized.length; i++) {
    if (i != 0 && i % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(normalized[i]);
  }
  return buffer.toString();
}
