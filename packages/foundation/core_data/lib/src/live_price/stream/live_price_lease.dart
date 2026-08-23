import '../models/live_instrument_seed.dart';
import '../models/live_price_batch.dart';

abstract interface class LivePriceLease {
  Stream<LivePriceBatch> get stream;
  Future<void> update(Iterable<LiveInstrumentSeed> instruments);
  Future<void> dispose();
}
