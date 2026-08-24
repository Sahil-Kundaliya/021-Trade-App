import 'package:flutter/widgets.dart';

enum MarketPriceDisplayMode { absoluteAndPercent, percentOnly, absoluteOnly }

class MarketPriceDisplayScope extends InheritedWidget {
  const MarketPriceDisplayScope({
    required this.mode,
    required super.child,
    super.key,
  });

  final MarketPriceDisplayMode mode;

  static MarketPriceDisplayMode of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MarketPriceDisplayScope>()
          ?.mode ??
      MarketPriceDisplayMode.absoluteAndPercent;

  @override
  bool updateShouldNotify(MarketPriceDisplayScope oldWidget) =>
      mode != oldWidget.mode;
}
