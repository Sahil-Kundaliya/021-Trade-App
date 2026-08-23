import '../models/fund_dto.dart';
import '../models/holding_dto.dart';
import '../models/market_index_dto.dart';

abstract interface class TradingLocalApi {
  Future<List<FundDto>> getFunds();

  Future<List<HoldingDto>> getHoldings();

  Future<List<MarketIndexDto>> getMarketIndices();
}
