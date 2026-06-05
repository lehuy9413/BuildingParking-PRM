import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVnd(num amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}