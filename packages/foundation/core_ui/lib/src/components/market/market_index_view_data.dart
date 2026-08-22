import 'package:flutter/foundation.dart';

/// Presentation-only data consumed by the shared market indices components.
@immutable
final class MarketIndexViewData {
  const MarketIndexViewData({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.isPositive,
  });

  final String name;
  final String value;
  final String change;
  final String changePercent;
  final bool isPositive;
}
