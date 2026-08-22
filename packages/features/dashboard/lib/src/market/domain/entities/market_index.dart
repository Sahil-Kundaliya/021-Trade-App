final class MarketIndex {
  const MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });

  final String name;
  final double value;
  final double change;
  final double changePercent;
}
