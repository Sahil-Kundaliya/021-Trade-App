class WatchlistStock {
  const WatchlistStock({
    required this.symbol,
    required this.companyName,
    required this.category,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required this.isBookmarked,
    this.tags = const <String>[],
  });

  final String symbol;
  final String companyName;
  final String category;
  final double ltp;
  final double change;
  final double changePercent;
  final bool isBookmarked;
  final List<String> tags;
}
