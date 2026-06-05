import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }
}