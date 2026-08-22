abstract final class PortfolioNumberFormat {
  static String currency(double value) => '\u20B9${number(value)}';

  static String signedCurrency(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign\u20B9${number(value.abs())}';
  }

  static String percentage(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign${value.abs().toStringAsFixed(2)}%';
  }

  static String number(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts.first;

    if (whole.length <= 3) return '$whole.${parts.last}';

    final lastThree = whole.substring(whole.length - 3);
    final leading = whole.substring(0, whole.length - 3);
    final groupedLeading = leading.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (_) => ',',
    );
    return '$groupedLeading,$lastThree.${parts.last}';
  }
}
