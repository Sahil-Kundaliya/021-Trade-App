import '../models/fund_dto.dart';
import '../models/holding_dto.dart';

abstract interface class TradingLocalApi {
  Future<List<FundDto>> getFunds();

  Future<List<HoldingDto>> getHoldings();
}
