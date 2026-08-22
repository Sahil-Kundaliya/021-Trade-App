class Holding {
  const Holding({
    required this.id,
    required this.fundId,
    required this.symbol,
    required this.companyName,
    required this.category,
    required this.instrumentType,
    required this.exchange,
    required this.quantity,
    required this.lots,
    required this.lotSize,
    required this.averageCost,
    required this.ltp,
    required this.investedValue,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
    required this.marginBlocked,
  });

  final String id;
  final String fundId;
  final String symbol;
  final String companyName;
  final String category;
  final String instrumentType;
  final String exchange;
  final int quantity;
  final int? lots;
  final int lotSize;
  final double averageCost;
  final double ltp;
  final double investedValue;
  final double currentValue;
  final double pnl;
  final double pnlPercent;
  final double marginBlocked;
}
