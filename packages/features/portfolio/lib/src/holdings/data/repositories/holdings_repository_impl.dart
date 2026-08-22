import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/holding.dart';
import '../../domain/repositories/holdings_repository.dart';
import '../mappers/holding_mapper.dart';

@LazySingleton(as: HoldingsRepository)
final class HoldingsRepositoryImpl implements HoldingsRepository {
  HoldingsRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;

  @override
  Future<List<Holding>> getHoldings() async {
    final dtos = await _tradingLocalApi.getHoldings();
    return dtos.map(HoldingMapper.toDomain).toList(growable: false);
  }
}
