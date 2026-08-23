import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/holding.dart';
import '../../domain/repositories/holdings_repository.dart';

@LazySingleton(as: HoldingsRepository)
final class HoldingsRepositoryImpl implements HoldingsRepository {
  HoldingsRepositoryImpl(this._positions);

  final PositionService _positions;

  @override
  Future<List<Holding>> getHoldings() async =>
      (await _positions.getPositions()).map(_toHolding).toList(growable: false);

  @override
  Stream<List<Holding>> get holdingChanges => _positions.positionChanges.map(
    (positions) => positions.map(_toHolding).toList(growable: false),
  );

  static Holding _toHolding(DerivedPosition position) {
    final invested = position.quantity * position.averageCost;
    final current = position.quantity * position.staticLtp;
    final pnl = current - invested;
    return Holding(
      id: position.marketKey,
      fundId: position.fundId,
      symbol: position.symbol,
      companyName: position.companyName,
      category: position.category,
      instrumentType: position.instrumentType.toUpperCase(),
      exchange: position.exchange.name,
      quantity: position.quantity,
      lots: position.lots,
      lotSize: position.lotSize,
      averageCost: position.averageCost,
      ltp: position.staticLtp,
      investedValue: invested,
      currentValue: current,
      pnl: pnl,
      pnlPercent: invested == 0 ? 0 : pnl / invested * 100,
      marginBlocked: 0,
      previousClose: position.previousClose,
      tickSize: position.tickSize,
    );
  }
}
