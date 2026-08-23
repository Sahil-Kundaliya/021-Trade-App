import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../models/live_instrument_seed.dart';
import 'live_price_platform_api.dart';

@LazySingleton(as: LivePricePlatformApi)
final class LivePricePlatformApiImpl implements LivePricePlatformApi {
  const LivePricePlatformApiImpl();

  static const _control = MethodChannel('light_trade_streamer/control');
  static const _prices = EventChannel('light_trade_streamer/prices');

  @override
  Stream<Object?> get batches => _prices.receiveBroadcastStream();

  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {
    final payload = instruments.map((seed) => seed.toMessage()).toList();
    if (payload.isEmpty) return;
    await _control.invokeMethod<void>('subscribe', {'instruments': payload});
  }

  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {
    final ids = instrumentIds.toList(growable: false);
    if (ids.isEmpty) return;
    await _control.invokeMethod<void>('unsubscribe', {'instrumentIds': ids});
  }

  @override
  Future<void> pause() => _control.invokeMethod<void>('pause');

  @override
  Future<void> resume() => _control.invokeMethod<void>('resume');
}
