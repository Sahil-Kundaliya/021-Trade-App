import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/fund_details.dart';
import '../../domain/repositories/fund_repository.dart';
import '../mappers/fund_details_mapper.dart';

@LazySingleton(as: FundRepository)
final class FundRepositoryImpl implements FundRepository {
  const FundRepositoryImpl(this._tradingLocalApi);
  final TradingLocalApi _tradingLocalApi;

  @override
  Future<FundDetails> getFundById(
    String fundId, {
    TradeExchange exchange = TradeExchange.nse,
  }) async {
    final funds = await _tradingLocalApi.getFunds();
    for (final fund in funds) {
      if (fund.id == fundId) {
        return FundDetailsMapper.toDomain(fund.forExchange(exchange));
      }
    }
    throw FundNotFoundException(fundId);
  }
}
