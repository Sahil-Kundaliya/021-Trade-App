enum FundActivityType { deposit, withdrawal }

class FundActivity {
  const FundActivity({
    required this.type,
    required this.amount,
    required this.title,
    required this.method,
    required this.dateLabel,
  });

  final FundActivityType type;
  final double amount;
  final String title;
  final String method;
  final String dateLabel;
}
