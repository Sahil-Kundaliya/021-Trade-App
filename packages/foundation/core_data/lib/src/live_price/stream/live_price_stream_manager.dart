import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../exceptions/live_price_exception.dart';
import '../models/live_instrument_seed.dart';
import '../models/live_price_batch.dart';
import '../models/live_price_tick.dart';
import '../platform/live_price_platform_api.dart';
import 'live_price_lease.dart';
import '../../market/trade_exchange.dart';

@lazySingleton
class LivePriceStreamManager with WidgetsBindingObserver {
  LivePriceStreamManager(this._platform);

  final LivePricePlatformApi _platform;
  final Map<String, int> _referenceCounts = {};
  final Map<String, LiveInstrumentSeed> _activeSeeds = {};
  final Map<int, _Lease> _leases = {};
  final Map<String, LivePriceTick> _latest = {};
  StreamSubscription<Object?>? _nativeSubscription;
  Future<void> _operations = Future<void>.value();
  int _nextConsumerId = 0;
  int _lastSequence = -1;
  bool _observingLifecycle = false;

  Map<String, LivePriceTick> get latestByInstrumentId =>
      Map<String, LivePriceTick>.unmodifiable(_latest);

  LivePriceTick? latestFor(String instrumentId) => _latest[instrumentId];

  LivePriceLease acquire({required Iterable<LiveInstrumentSeed> instruments}) {
    _ensureConnected();
    final lease = _Lease(++_nextConsumerId, this);
    _leases[lease.id] = lease;
    unawaited(
      lease.update(instruments).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        lease.addError(
          LivePriceException('Unable to subscribe to live prices.', error),
          stackTrace,
        );
      }),
    );
    return lease;
  }

  void _ensureConnected() {
    if (_nativeSubscription != null) return;
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
    _nativeSubscription = _platform.batches.listen(
      _handleNativeBatch,
      onError: (Object error, StackTrace stackTrace) {
        final exception = LivePriceException(
          'Native price stream failed.',
          error,
        );
        for (final lease in _leases.values) {
          lease.addError(exception, stackTrace);
        }
      },
    );
  }

  Future<void> _updateLease(
    _Lease lease,
    Iterable<LiveInstrumentSeed> instruments,
  ) => _serialize(() async {
    if (lease.disposed) return;
    final next = <String, LiveInstrumentSeed>{};
    for (final seed in instruments) {
      if (seed.instrumentId.isEmpty ||
          seed.ltpMinor <= 0 ||
          seed.previousCloseMinor <= 0 ||
          seed.tickSizeMinor <= 0) {
        throw const LivePriceException('Invalid live instrument seed.');
      }
      next[seed.instrumentId] = seed;
    }
    final oldIds = lease.seeds.keys.toSet();
    final nextIds = next.keys.toSet();
    final removed = oldIds.difference(nextIds);
    final added = nextIds.difference(oldIds);
    final nativeUnsubscribe = <String>[];
    final nativeSubscribe = <LiveInstrumentSeed>[];

    for (final id in removed) {
      final count = (_referenceCounts[id] ?? 0) - 1;
      if (count <= 0) {
        _referenceCounts.remove(id);
        _activeSeeds.remove(id);
        nativeUnsubscribe.add(id);
      } else {
        _referenceCounts[id] = count;
      }
    }
    for (final id in added) {
      final count = _referenceCounts[id] ?? 0;
      _referenceCounts[id] = count + 1;
      if (count == 0) {
        final seed = next[id]!;
        _activeSeeds[id] = seed;
        nativeSubscribe.add(seed);
      }
    }
    lease.seeds = next;
    await _platform.unsubscribe(nativeUnsubscribe);
    await _platform.subscribe(nativeSubscribe);
  });

  Future<void> _disposeLease(_Lease lease) => _serialize(() async {
    if (lease.disposed) return;
    final ids = lease.seeds.keys.toList(growable: false);
    final nativeUnsubscribe = <String>[];
    for (final id in ids) {
      final count = (_referenceCounts[id] ?? 0) - 1;
      if (count <= 0) {
        _referenceCounts.remove(id);
        _activeSeeds.remove(id);
        nativeUnsubscribe.add(id);
      } else {
        _referenceCounts[id] = count;
      }
    }
    lease.disposed = true;
    lease.seeds = const {};
    _leases.remove(lease.id);
    await _platform.unsubscribe(nativeUnsubscribe);
    await lease.close();
  });

  Future<void> _serialize(Future<void> Function() operation) {
    final result = _operations.then((_) => operation());
    _operations = result.catchError((Object _) {});
    return result;
  }

  void _handleNativeBatch(Object? raw) {
    try {
      final batch = LivePriceBatch.fromMessage(raw);
      if (batch.sequence <= _lastSequence) return;
      _lastSequence = batch.sequence;
      final normalized = <LivePriceTick>[];
      for (final rawTick in batch.updates) {
        final tick = _normalizeLegacyTick(rawTick);
        if (tick != null) {
          _latest[tick.instrumentId] = tick;
          normalized.add(tick);
        }
      }
      for (final lease in _leases.values.toList(growable: false)) {
        final filtered = normalized
            .where((tick) => lease.seeds.containsKey(tick.instrumentId))
            .toList(growable: false);
        if (filtered.isNotEmpty) {
          lease.add(
            LivePriceBatch(
              sequence: batch.sequence,
              timestamp: batch.timestamp,
              updates: List<LivePriceTick>.unmodifiable(filtered),
            ),
          );
        }
      }
    } on Object catch (error, stackTrace) {
      final exception = LivePriceException(
        'Invalid native price batch.',
        error,
      );
      for (final lease in _leases.values) {
        lease.addError(exception, stackTrace);
      }
    }
  }

  LivePriceTick? _normalizeLegacyTick(LivePriceTick tick) {
    if (_referenceCounts.containsKey(tick.instrumentId)) return tick;
    final candidates = _activeSeeds.values
        .where(
          (seed) =>
              seed.fundId == tick.instrumentId &&
              seed.exchange == TradeExchange.nse,
        )
        .toList(growable: false);
    if (candidates.length != 1) return null;
    return tick.withInstrumentId(candidates.single.marketKey);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_platform.resume());
      case AppLifecycleState.inactive ||
          AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        unawaited(_platform.pause());
    }
  }
}

final class _Lease implements LivePriceLease {
  _Lease(this.id, this.manager);

  final int id;
  final LivePriceStreamManager manager;
  final StreamController<LivePriceBatch> _controller =
      StreamController<LivePriceBatch>.broadcast(sync: true);
  Map<String, LiveInstrumentSeed> seeds = const {};
  bool disposed = false;

  @override
  Stream<LivePriceBatch> get stream => _controller.stream;

  @override
  Future<void> update(Iterable<LiveInstrumentSeed> instruments) =>
      manager._updateLease(this, instruments);

  @override
  Future<void> dispose() => manager._disposeLease(this);

  void add(LivePriceBatch batch) {
    if (!disposed) _controller.add(batch);
  }

  void addError(Object error, StackTrace stackTrace) {
    if (!disposed) _controller.addError(error, stackTrace);
  }

  Future<void> close() => _controller.close();
}
