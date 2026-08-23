import 'package:core_data/core_data.dart';

import '../../domain/entities/holding.dart';

abstract final class HoldingMapper {
  static Holding toDomain(HoldingDto dto, FundDto fund) => Holding(
    id: dto.id,
    fundId: dto.fundId,
    symbol: dto.symbol,
    companyName: dto.companyName,
    category: dto.category,
    instrumentType: dto.instrumentType,
    exchange: dto.exchange,
    quantity: dto.quantity,
    lots: dto.lots,
    lotSize: dto.lotSize,
    averageCost: dto.averageCost,
    ltp: dto.ltp,
    investedValue: dto.investedValue,
    currentValue: dto.currentValue,
    pnl: dto.pnl,
    pnlPercent: dto.pnlPercent,
    marginBlocked: dto.marginBlocked,
    previousClose: fund.previousClose,
    tickSize: fund.tickSize,
  );
}
