class WatchlistFund {
  WatchlistFund({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.category,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required List<String> tags,
  }) : tags = List<String>.unmodifiable(tags);

  final String id;
  final String symbol;
  final String companyName;
  final String exchange;
  final String category;
  final double ltp;
  final double change;
  final double changePercent;
  final List<String> tags;
}
