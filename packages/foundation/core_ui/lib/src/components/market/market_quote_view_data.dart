import 'package:flutter/foundation.dart';

import '../../formatters/financial_formatter.dart';
import 'live_value_flash.dart';

@immutable
final class MarketQuoteViewData {
  const MarketQuoteViewData({
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.liveDirection = LiveValueDirection.flat,
    this.liveUpdateId,
  });

  final double ltp;
  final double change;
  final double changePercent;
  final LiveValueDirection liveDirection;
  final int? liveUpdateId;

  int get displaySign => FinancialFormatter.displaySign(change, changePercent);

  bool get isPositive => displaySign > 0;
  bool get isNegative => displaySign < 0;
  bool get isFlat => displaySign == 0;

  @override
  bool operator ==(Object other) =>
      other is MarketQuoteViewData &&
      other.ltp == ltp &&
      other.change == change &&
      other.changePercent == changePercent &&
      other.liveDirection == liveDirection &&
      other.liveUpdateId == liveUpdateId;

  @override
  int get hashCode =>
      Object.hash(ltp, change, changePercent, liveDirection, liveUpdateId);
}
