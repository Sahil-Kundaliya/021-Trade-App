abstract final class FinancialFormatter {
  static const _rupee = '₹';

  static double normalize(double value) {
    final rounded = double.parse(value.toStringAsFixed(2));
    return rounded == 0 ? 0 : rounded;
  }

  static int displaySign(double change, [double? changePercent]) {
    final normalizedChange = normalize(change);
    if (normalizedChange > 0) return 1;
    if (normalizedChange < 0) return -1;
    if (changePercent != null) {
      final normalizedPercent = normalize(changePercent);
      if (normalizedPercent > 0) return 1;
      if (normalizedPercent < 0) return -1;
    }
    return 0;
  }

  static String decimals(double value) {
    final normalized = normalize(value);
    if (normalized == 0) return '0.00';
    return normalized.toStringAsFixed(2);
  }

  static String group(String source) {
    final parts = source.split('.');
    var whole = parts.first;
    final negative = whole.startsWith('-');
    if (negative) whole = whole.substring(1);
    if (whole.length > 3) {
      final end = whole.substring(whole.length - 3);
      var start = whole.substring(0, whole.length - 3);
      final groups = <String>[];
      while (start.length > 2) {
        groups.insert(0, start.substring(start.length - 2));
        start = start.substring(0, start.length - 2);
      }
      if (start.isNotEmpty) groups.insert(0, start);
      whole = '${groups.join(',')},$end';
    }
    return '${negative ? '-' : ''}$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  static String price(num? value, {bool symbol = true}) {
    if (value == null) return '—';
    final normalized = normalize(value.toDouble());
    final amount = group(decimals(normalized.abs()));
    final signed = normalized < 0 ? '-$amount' : amount;
    return symbol ? '$_rupee$signed' : signed;
  }

  static String change(double value) {
    final normalized = normalize(value);
    if (normalized == 0) return '0.00';
    final amount = group(decimals(normalized.abs()));
    return normalized > 0 ? '+$amount' : '-$amount';
  }

  static String percentage(double value) {
    final normalized = normalize(value);
    if (normalized == 0) return '0.00%';
    final amount = '${decimals(normalized.abs())}%';
    return normalized > 0 ? '+$amount' : '-$amount';
  }

  static String signedPrice(double value) {
    final normalized = normalize(value);
    if (normalized == 0) return '${_rupee}0.00';
    final amount = '$_rupee${group(decimals(normalized.abs()))}';
    return normalized > 0 ? '+$amount' : '-$amount';
  }

  static String changeGroup(double changeValue, double changePercent) =>
      '${change(changeValue)} (${percentage(changePercent)})';
}
