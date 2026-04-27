import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _currencyFormatWithDecimals = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount) {
    if (amount % 1 == 0) {
      return _currencyFormat.format(amount);
    }
    return _currencyFormatWithDecimals.format(amount);
  }
}
