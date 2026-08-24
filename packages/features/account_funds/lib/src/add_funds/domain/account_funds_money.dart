abstract final class AccountFundsMoney {
  static const double maxAddRupees = 10000;
  static const int maxAddPaise = 1000000;
  static const List<double> quickAddRupees = <double>[500, 1000, 2500, 5000];

  static const greaterThanZeroMessage = 'Enter an amount greater than ₹0.';
  static const maxPerAddMessage = 'You can add a maximum of ₹10,000 at a time.';
  static const addSuccessMessage = 'Funds added successfully.';
  static const addFailureMessage = 'Unable to add funds. Try again.';
  static const loadFailureMessage = 'Unable to load account funds.';

  static int toPaise(double rupees) {
    final normalized = double.parse(rupees.toStringAsFixed(2));
    if (normalized == 0) return 0;
    return (normalized * 100).round();
  }

  static double? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed == '.') return null;
    return double.tryParse(trimmed);
  }

  static String? validationMessage(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      return input.trim().isEmpty ? null : greaterThanZeroMessage;
    }
    final paise = toPaise(parsed);
    if (paise <= 0) return greaterThanZeroMessage;
    if (paise > maxAddPaise) return maxPerAddMessage;
    return null;
  }
}
