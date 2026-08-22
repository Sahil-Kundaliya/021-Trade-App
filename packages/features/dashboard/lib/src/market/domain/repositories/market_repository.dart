import '../entities/market_instrument.dart';

abstract interface class MarketRepository {
  Future<List<MarketInstrument>> getFunds();
}
