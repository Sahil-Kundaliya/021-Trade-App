class Holding {
  const Holding({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.averageCost,
    required this.ltp,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
  });

  final String symbol;
  final String companyName;
  final int quantity;
  final double averageCost;
  final double ltp;
  final double currentValue;
  final double pnl;
  final double pnlPercent;
}
