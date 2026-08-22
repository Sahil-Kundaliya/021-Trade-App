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
}
