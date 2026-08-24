import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../../domain/repositories/heat_map_repository.dart';
import '../mappers/heat_map_fund_mapper.dart';

@LazySingleton(as: HeatMapRepository)
final class HeatMapRepositoryImpl implements HeatMapRepository {
  HeatMapRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;

  @override
  Future<List<HeatMapFund>> getEquityFunds({
    required TradeExchange exchange,
  }) async {
    final dtos = await _tradingLocalApi.getFunds();
    return dtos
        .where((fund) => fund.category == 'Equity')
        .where((fund) => fund.listingFor(exchange) != null)
        .map((fund) => HeatMapFundMapper.toDomain(fund.forExchange(exchange)))
        .toList(growable: false);
  }
}
