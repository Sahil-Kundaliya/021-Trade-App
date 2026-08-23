import 'package:flutter_test/flutter_test.dart';
import 'package:fund/src/fund_details/domain/entities/price_candle.dart';

void main() {
  final start = DateTime(2026, 8, 23, 10);

  PriceCandle candle({
    required int open,
    required int high,
    required int low,
    required int close,
    DateTime? at,
  }) => PriceCandle(
    startedAt: at ?? start,
    openMinor: open,
    highMinor: high,
    lowMinor: low,
    closeMinor: close,
  );

  test('up tick raises high and close', () {
    final update = CandleAggregator.apply(
      historical: const [],
      active: candle(open: 10000, high: 10200, low: 9900, close: 10100),
      ltpMinor: 10300,
      timestamp: start.add(const Duration(seconds: 5)),
    );
    expect(update.active.openMinor, 10000);
    expect(update.active.highMinor, 10300);
    expect(update.active.lowMinor, 9900);
    expect(update.active.closeMinor, 10300);
    expect(update.historical, isEmpty);
  });

  test('down tick lowers low and close', () {
    final update = CandleAggregator.apply(
      historical: const [],
      active: candle(open: 10000, high: 10300, low: 9900, close: 10300),
      ltpMinor: 9800,
      timestamp: start.add(const Duration(seconds: 5)),
    );
    expect(update.active.highMinor, 10300);
    expect(update.active.lowMinor, 9800);
    expect(update.active.closeMinor, 9800);
  });

  test('flat tick is accepted without changing the candle', () {
    final active = candle(open: 10000, high: 10200, low: 9900, close: 10100);
    final update = CandleAggregator.apply(
      historical: const [],
      active: active,
      ltpMinor: 10100,
      timestamp: start.add(const Duration(seconds: 1)),
    );
    expect(update.active.closeMinor, 10100);
    expect(update.active.highMinor, 10200);
    expect(update.active.lowMinor, 9900);
  });

  test('minute boundary finalizes the candle and opens a new one', () {
    final update = CandleAggregator.apply(
      historical: const [],
      active: candle(open: 10000, high: 10200, low: 9900, close: 10100),
      ltpMinor: 10400,
      timestamp: start.add(const Duration(minutes: 1)),
    );
    expect(update.historical, hasLength(1));
    expect(update.historical.single.closeMinor, 10100);
    expect(update.active.openMinor, 10400);
    expect(update.active.highMinor, 10400);
    expect(update.active.lowMinor, 10400);
    expect(update.active.closeMinor, 10400);
  });

  test('history stays bounded', () {
    var historical = <PriceCandle>[
      for (var i = 0; i < CandleAggregator.maxCandles; i++)
        candle(
          open: 10000,
          high: 10100,
          low: 9900,
          close: 10050,
          at: start.subtract(Duration(minutes: CandleAggregator.maxCandles - i)),
        ),
    ];
    var active = candle(open: 10000, high: 10100, low: 9900, close: 10050);
    for (var i = 0; i < 5; i++) {
      final update = CandleAggregator.apply(
        historical: historical,
        active: active,
        ltpMinor: 10500 + i,
        timestamp: start.add(Duration(minutes: i + 1)),
      );
      historical = update.historical;
      active = update.active;
    }
    expect(historical.length, lessThanOrEqualTo(CandleAggregator.maxCandles));
    expect(
      historical.first.startedAt.isBefore(historical.last.startedAt),
      isTrue,
    );
  });

  test('daily bucket updates the same candle across minute ticks', () {
    final day = DateTime(2026, 8, 21, 9, 15);
    var historical = <PriceCandle>[];
    var active = candle(open: 10000, high: 10100, low: 9900, close: 10050, at: day);
    for (var i = 0; i < 120; i++) {
      final update = CandleAggregator.apply(
        historical: historical,
        active: active,
        ltpMinor: 10050 + i,
        timestamp: day.add(Duration(minutes: i)),
        bucket: CandleBucket.day,
      );
      historical = update.historical;
      active = update.active;
    }
    expect(historical, isEmpty);
    expect(active.startedAt, DateTime(2026, 8, 21, 9, 15));
    expect(active.openMinor, 10000);
    expect(active.closeMinor, 10169);
    expect(active.highMinor, 10169);
  });

  test('daily bucket opens a new candle on the next day', () {
    final update = CandleAggregator.apply(
      historical: const [],
      active: candle(
        open: 10000,
        high: 10200,
        low: 9900,
        close: 10100,
        at: DateTime(2026, 8, 21, 9, 15),
      ),
      ltpMinor: 10400,
      timestamp: DateTime(2026, 8, 24, 10, 15),
      bucket: CandleBucket.day,
    );
    expect(update.historical, hasLength(1));
    expect(update.historical.single.closeMinor, 10100);
    expect(update.active.startedAt, DateTime(2026, 8, 24));
    expect(update.active.openMinor, 10400);
  });
}
