import '../entities/holding.dart';

abstract interface class HoldingsRepository {
  Future<List<Holding>> getHoldings();
  Stream<List<Holding>> get holdingChanges;
}
