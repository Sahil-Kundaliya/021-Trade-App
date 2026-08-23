import 'package:flutter/foundation.dart';

import '../../formatters/financial_formatter.dart';

@immutable
final class MarketQuoteViewData {
  const MarketQuoteViewData({
    required this.ltp,
    required this.change,
    required this.changePercent,
  });

  final double ltp;
  final double change;
  final double changePercent;

  int get displaySign =>
      FinancialFormatter.displaySign(change, changePercent);

  bool get isPositive => displaySign > 0;
  bool get isNegative => displaySign < 0;
  bool get isFlat => displaySign == 0;

  @override
  bool operator ==(Object other) =>
      other is MarketQuoteViewData &&
      other.ltp == ltp &&
      other.change == change &&
      other.changePercent == changePercent;

  @override
  int get hashCode => Object.hash(ltp, change, changePercent);
}
