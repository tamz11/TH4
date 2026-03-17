import 'package:intl/intl.dart';

final NumberFormat _vndFormatter = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

String formatVnd(num value) {
  // If price is unusually small (like 30 or 150), it means the API/data
  // represents the price in thousands (k). We multiply it by 1000.
  // We check bounds to not accidentally multiply the already 30000 shipping_fee!
  double finalValue = value.toDouble();
  if (finalValue > 0 && finalValue < 10000) {
    finalValue = finalValue * 1000;
  }

  return _vndFormatter.format(finalValue);
}
