import 'package:flutter/foundation.dart';

@immutable
final class MarketIndexViewData {
  const MarketIndexViewData({
    required this.id,
    required this.name,
    required this.ltp,
    required this.change,
    required this.changePercent,
  });

  final String id;
  final String name;
  final double ltp;
  final double change;
  final double changePercent;

  @override
  bool operator ==(Object other) =>
      other is MarketIndexViewData &&
      other.id == id &&
      other.name == name &&
      other.ltp == ltp &&
      other.change == change &&
      other.changePercent == changePercent;

  @override
  int get hashCode => Object.hash(id, name, ltp, change, changePercent);
}
