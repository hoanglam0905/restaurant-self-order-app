String formatAppPrice(double value, {bool withCurrency = false}) {
  if (value > 0 && value < 1000) {
    final price = value.toStringAsFixed(2);
    return withCurrency ? '\$$price' : price;
  }

  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final reverseIndex = rounded.length - i;
    buffer.write(rounded[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return withCurrency ? '$bufferđ' : buffer.toString();
}
