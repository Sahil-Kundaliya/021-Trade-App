import 'package:core_data/core_data.dart';

import '../../domain/entities/heat_map_fund.dart';

abstract final class HeatMapFundMapper {
  static HeatMapFund toDomain(FundDto dto) {
    final weight = dto.heatmapWeight ?? dto.ltp * dto.volume;
    return HeatMapFund(
      fundId: dto.id,
      exchange: TradeExchange.parse(dto.exchange),
      symbol: dto.symbol,
      companyName: dto.companyName,
      heatMapWeight: weight > 0 ? weight : 1,
      initialLtp: dto.ltp,
      previousClose: dto.previousClose,
      tickSize: dto.tickSize,
    );
  }
}
