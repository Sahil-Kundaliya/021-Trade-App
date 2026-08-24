import 'package:flutter/foundation.dart';

import 'live_value_flash.dart';

@immutable
final class MarketIndexViewData {
  const MarketIndexViewData({
    required this.id,
    required this.name,
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.liveDirection = LiveValueDirection.flat,
    this.liveUpdateId,
  });

  final String id;
  final String name;
  final double ltp;
  final double change;
  final double changePercent;
  final LiveValueDirection liveDirection;
  final int? liveUpdateId;

  @override
  bool operator ==(Object other) =>
      other is MarketIndexViewData &&
      other.id == id &&
      other.name == name &&
      other.ltp == ltp &&
      other.change == change &&
      other.changePercent == changePercent &&
      other.liveDirection == liveDirection &&
      other.liveUpdateId == liveUpdateId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ltp,
    change,
    changePercent,
    liveDirection,
    liveUpdateId,
  );
}
