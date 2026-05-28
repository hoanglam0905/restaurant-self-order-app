import '../../../../../core/utils/app_price_formatter.dart';

String formatMenuPrice(double value, {bool withCurrency = false}) {
  return formatAppPrice(value, withCurrency: withCurrency);
}
