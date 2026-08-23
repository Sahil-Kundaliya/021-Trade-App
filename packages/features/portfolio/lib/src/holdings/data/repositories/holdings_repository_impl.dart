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
    final results = await Future.wait([
      _tradingLocalApi.getHoldings(),
      _tradingLocalApi.getFunds(),
    ]);
    final dtos = results[0] as List<HoldingDto>;
    final funds = results[1] as List<FundDto>;
    final byId = {for (final fund in funds) fund.id: fund};
    return dtos
        .where((dto) => byId.containsKey(dto.fundId))
        .map((dto) => HoldingMapper.toDomain(dto, byId[dto.fundId]!))
        .toList(growable: false);
  }
}
