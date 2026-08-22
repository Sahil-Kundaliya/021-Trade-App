import '../entities/holding.dart';

abstract interface class HoldingsRepository {
  Future<List<Holding>> getHoldings();
}
