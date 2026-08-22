class MarginBreakdown {
  const MarginBreakdown({
    required this.total,
    required this.span,
    required this.exposure,
    required this.optionPremium,
    required this.deliveryMargin,
  });

  final double total;
  final double span;
  final double exposure;
  final double optionPremium;
  final double deliveryMargin;
}
