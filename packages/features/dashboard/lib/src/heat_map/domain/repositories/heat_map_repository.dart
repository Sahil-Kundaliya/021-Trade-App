import 'package:core_data/core_data.dart';

import '../entities/heat_map_fund.dart';

abstract interface class HeatMapRepository {
  Future<List<HeatMapFund>> getEquityFunds({required TradeExchange exchange});
}
