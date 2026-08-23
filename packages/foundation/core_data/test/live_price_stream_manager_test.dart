import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tcs = LiveInstrumentSeed(
    instrumentId: 'TCS_EQ',
    symbol: 'TCS',
    ltpMinor: 230200,
    previousCloseMinor: 229800,
    tickSizeMinor: 5,
  );
  const sbin = LiveInstrumentSeed(
    instrumentId: 'SBIN_EQ',
    symbol: 'SBIN',
    ltpMinor: 104800,
    previousCloseMinor: 104000,
    tickSizeMinor: 5,
  );

  test(
    'deduplicates native subscribe and unsubscribes on final release',
    () async {
      final platform = _FakePlatform();
      final manager = LivePriceStreamManager(platform);
      final first = manager.acquire(instruments: [tcs]);
      final second = manager.acquire(instruments: [tcs]);
      await _flush();

      expect(platform.subscribed, [
        const ['TCS_EQ'],
      ]);
      await first.dispose();
      expect(platform.unsubscribed, isEmpty);
      await second.dispose();
      expect(platform.unsubscribed, [
        const ['TCS_EQ'],
      ]);
      await platform.close();
    },
  );

  test(
    'filters batches per lease, caches latest, and delivers flat ticks',
    () async {
      final platform = _FakePlatform();
      final manager = LivePriceStreamManager(platform);
      final tcsLease = manager.acquire(instruments: [tcs]);
      final sbinLease = manager.acquire(instruments: [sbin]);
      final tcsBatches = <LivePriceBatch>[];
      final sbinBatches = <LivePriceBatch>[];
      final tcsSub = tcsLease.stream.listen(tcsBatches.add);
      final sbinSub = sbinLease.stream.listen(sbinBatches.add);
      await _flush();

      platform.emit(
        _batch(1, [
          _tick(
            tcs,
            ltpMinor: 230200,
            previousLtpMinor: 230200,
            direction: 'flat',
          ),
          _tick(
            sbin,
            ltpMinor: 104805,
            previousLtpMinor: 104800,
            direction: 'up',
          ),
        ]),
      );
      await _flush();

      expect(
        tcsBatches.single.updates.single.direction,
        LivePriceDirection.flat,
      );
      expect(tcsBatches.single.updates.single.instrumentId, 'TCS_EQ');
      expect(sbinBatches.single.updates.single.instrumentId, 'SBIN_EQ');
      expect(manager.latestFor('SBIN_EQ')?.ltpMinor, 104805);

      await tcsSub.cancel();
      await sbinSub.cancel();
      await tcsLease.dispose();
      await sbinLease.dispose();
      await platform.close();
    },
  );

  test(
    'lease update sends only set deltas and dispose is idempotent',
    () async {
      final platform = _FakePlatform();
      final manager = LivePriceStreamManager(platform);
      final lease = manager.acquire(instruments: [tcs]);
      await _flush();
      await lease.update([sbin]);

      expect(platform.subscribed, [
        const ['TCS_EQ'],
        const ['SBIN_EQ'],
      ]);
      expect(platform.unsubscribed, [
        const ['TCS_EQ'],
      ]);
      await lease.dispose();
      await lease.dispose();
      expect(platform.unsubscribed, [
        const ['TCS_EQ'],
        const ['SBIN_EQ'],
      ]);
      await platform.close();
    },
  );
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

Map<String, Object> _batch(int sequence, List<Map<String, Object>> updates) => {
  'sequence': sequence,
  'timestamp': 1787460000000,
  'updates': updates,
};

Map<String, Object> _tick(
  LiveInstrumentSeed seed, {
  required int ltpMinor,
  required int previousLtpMinor,
  required String direction,
}) {
  final change = ltpMinor - seed.previousCloseMinor;
  return {
    'instrumentId': seed.instrumentId,
    'symbol': seed.symbol,
    'ltpMinor': ltpMinor,
    'previousLtpMinor': previousLtpMinor,
    'previousCloseMinor': seed.previousCloseMinor,
    'changeMinor': change,
    'changePercent': change / seed.previousCloseMinor * 100,
    'direction': direction,
  };
}

final class _FakePlatform implements LivePricePlatformApi {
  final _controller = StreamController<Object?>.broadcast();
  final List<List<String>> subscribed = [];
  final List<List<String>> unsubscribed = [];

  @override
  Stream<Object?> get batches => _controller.stream;

  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {
    final ids = instruments.map((item) => item.instrumentId).toList();
    if (ids.isNotEmpty) subscribed.add(ids);
  }

  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {
    final ids = instrumentIds.toList();
    if (ids.isNotEmpty) unsubscribed.add(ids);
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  void emit(Object value) => _controller.add(value);
  Future<void> close() => _controller.close();
}
