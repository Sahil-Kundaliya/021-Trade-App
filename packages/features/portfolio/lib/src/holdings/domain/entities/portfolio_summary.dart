class PortfolioSummary {
  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  });

  final double totalInvested;
  final double currentValue;
  final double totalPnl;
  final double totalPnlPercent;

  @override
  bool operator ==(Object other) =>
      other is PortfolioSummary &&
      other.totalInvested == totalInvested &&
      other.currentValue == currentValue &&
      other.totalPnl == totalPnl &&
      other.totalPnlPercent == totalPnlPercent;

  @override
  int get hashCode =>
      Object.hash(totalInvested, currentValue, totalPnl, totalPnlPercent);
}
