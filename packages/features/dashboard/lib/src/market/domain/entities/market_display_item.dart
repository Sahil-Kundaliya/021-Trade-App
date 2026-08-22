class MarketDisplayItem {
  const MarketDisplayItem({
    required this.id,
    required this.symbol,
    required this.title,
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.expiry,
    this.strike,
    this.optionType,
    this.volume,
  });

  final String id;
  final String symbol;
  final String title;
  final String ltp;
  final String change;
  final double changePercent;
  final String? expiry;
  final String? strike;
  final String? optionType;
  final String? volume;
}
