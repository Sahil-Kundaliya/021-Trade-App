class FundSummary {
  const FundSummary({
    required this.availableToTrade,
    required this.withdrawableBalance,
    required this.availableCash,
    required this.usedMargin,
    required this.openingBalance,
    required this.addedToday,
    required this.withdrawnToday,
  });

  final double availableToTrade;
  final double withdrawableBalance;
  final double availableCash;
  final double usedMargin;
  final double openingBalance;
  final double addedToday;
  final double withdrawnToday;
}
