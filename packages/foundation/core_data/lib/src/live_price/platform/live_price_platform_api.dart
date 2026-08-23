import '../models/live_instrument_seed.dart';

abstract interface class LivePricePlatformApi {
  Stream<Object?> get batches;

  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments);
  Future<void> unsubscribe(Iterable<String> instrumentIds);
  Future<void> pause();
  Future<void> resume();
}
