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

  @override
  bool operator ==(Object other) =>
      other is PriceCandle &&
      other.startedAt == startedAt &&
      other.openMinor == openMinor &&
      other.highMinor == highMinor &&
      other.lowMinor == lowMinor &&
      other.closeMinor == closeMinor;

  @override
  int get hashCode =>
      Object.hash(startedAt, openMinor, highMinor, lowMinor, closeMinor);
}

class CandleSeriesUpdate {
  const CandleSeriesUpdate({required this.historical, required this.active});

  final List<PriceCandle> historical;
  final PriceCandle active;
}

enum CandleBucket {
  minute,
  day;

  DateTime startOf(DateTime timestamp) => switch (this) {
    CandleBucket.minute => DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      timestamp.hour,
      timestamp.minute,
    ),
    CandleBucket.day => DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    ),
  };

  int get maxCandles => switch (this) {
    CandleBucket.minute => 180,
    CandleBucket.day => 90,
  };
}

abstract final class CandleAggregator {
  static const int maxCandles = 180;
  static const Duration interval = Duration(minutes: 1);

  static DateTime bucketStart(DateTime timestamp) =>
      CandleBucket.minute.startOf(timestamp);

  static CandleSeriesUpdate seed({
    required List<PriceCandle> candles,
    required int ltpMinor,
    required DateTime timestamp,
    CandleBucket bucket = CandleBucket.minute,
  }) {
    if (candles.isEmpty) {
      return CandleSeriesUpdate(
        historical: const [],
        active: PriceCandle(
          startedAt: bucket.startOf(timestamp),
          openMinor: ltpMinor,
          highMinor: ltpMinor,
          lowMinor: ltpMinor,
          closeMinor: ltpMinor,
        ),
      );
    }
    final historical = List<PriceCandle>.of(candles);
    final last = historical.removeLast();
    return apply(
      historical: historical,
      active: last,
      ltpMinor: ltpMinor,
      timestamp: timestamp,
      bucket: bucket,
    );
  }

  static CandleSeriesUpdate apply({
    required List<PriceCandle> historical,
    required PriceCandle active,
    required int ltpMinor,
    required DateTime timestamp,
    CandleBucket bucket = CandleBucket.minute,
  }) {
    final start = bucket.startOf(timestamp);
    if (bucket.startOf(active.startedAt) == start) {
      final highMinor = ltpMinor > active.highMinor
          ? ltpMinor
          : active.highMinor;
      final lowMinor = ltpMinor < active.lowMinor ? ltpMinor : active.lowMinor;
      if (ltpMinor == active.closeMinor &&
          highMinor == active.highMinor &&
          lowMinor == active.lowMinor) {
        return CandleSeriesUpdate(historical: historical, active: active);
      }
      return CandleSeriesUpdate(
        historical: historical,
        active: PriceCandle(
          startedAt: active.startedAt,
          openMinor: active.openMinor,
          highMinor: highMinor,
          lowMinor: lowMinor,
          closeMinor: ltpMinor,
        ),
      );
    }

    final committed = [...historical, active];
    final max = bucket.maxCandles;
    final bounded = committed.length > max
        ? committed.sublist(committed.length - max)
        : committed;
    return CandleSeriesUpdate(
      historical: List<PriceCandle>.unmodifiable(bounded),
      active: PriceCandle(
        startedAt: start,
        openMinor: ltpMinor,
        highMinor: ltpMinor,
        lowMinor: ltpMinor,
        closeMinor: ltpMinor,
      ),
    );
  }
}
