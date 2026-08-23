class PriceCandle {
  const PriceCandle({
    required this.startedAt,
    required this.openMinor,
    required this.highMinor,
    required this.lowMinor,
    required this.closeMinor,
  });

  factory PriceCandle.fromPrices({
    required DateTime startedAt,
    required double open,
    required double high,
    required double low,
    required double close,
  }) => PriceCandle(
    startedAt: startedAt,
    openMinor: _toMinor(open),
    highMinor: _toMinor(high),
    lowMinor: _toMinor(low),
    closeMinor: _toMinor(close),
  );

  final DateTime startedAt;
  final int openMinor;
  final int highMinor;
  final int lowMinor;
  final int closeMinor;

  double get open => openMinor / 100;
  double get high => highMinor / 100;
  double get low => lowMinor / 100;
  double get close => closeMinor / 100;
  bool get isBullish => closeMinor >= openMinor;
  bool get isBearish => closeMinor < openMinor;

  static int _toMinor(double value) => (value * 100).round();
}

class CandleSeriesUpdate {
  const CandleSeriesUpdate({required this.historical, required this.active});

  final List<PriceCandle> historical;
  final PriceCandle active;
}

abstract final class CandleAggregator {
  static const int maxCandles = 180;
  static const Duration interval = Duration(minutes: 1);

  static DateTime bucketStart(DateTime timestamp) => DateTime(
    timestamp.year,
    timestamp.month,
    timestamp.day,
    timestamp.hour,
    timestamp.minute,
  );

  static CandleSeriesUpdate apply({
    required List<PriceCandle> historical,
    required PriceCandle active,
    required int ltpMinor,
    required DateTime timestamp,
  }) {
    final bucket = bucketStart(timestamp);
    if (bucketStart(active.startedAt) == bucket) {
      return CandleSeriesUpdate(
        historical: historical,
        active: PriceCandle(
          startedAt: active.startedAt,
          openMinor: active.openMinor,
          highMinor: ltpMinor > active.highMinor ? ltpMinor : active.highMinor,
          lowMinor: ltpMinor < active.lowMinor ? ltpMinor : active.lowMinor,
          closeMinor: ltpMinor,
        ),
      );
    }

    final committed = [...historical, active];
    final bounded = committed.length > maxCandles
        ? committed.sublist(committed.length - maxCandles)
        : committed;
    return CandleSeriesUpdate(
      historical: List<PriceCandle>.unmodifiable(bounded),
      active: PriceCandle(
        startedAt: bucket,
        openMinor: ltpMinor,
        highMinor: ltpMinor,
        lowMinor: ltpMinor,
        closeMinor: ltpMinor,
      ),
    );
  }
}
