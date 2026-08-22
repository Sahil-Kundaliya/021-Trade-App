import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/market_instrument.dart';
import '../../domain/repositories/market_repository.dart';
import '../mappers/fund_market_mapper.dart';

@LazySingleton(as: MarketRepository)
final class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;

  @override
  Future<List<MarketInstrument>> getFunds() async {
    final dtos = await _tradingLocalApi.getFunds();
    return dtos.map(FundMarketMapper.toDomain).toList(growable: false);
  }
}
