import 'package:core_data/core_data.dart';

import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_instrument.dart';

abstract final class FundMarketMapper {
  static MarketInstrument toDomain(FundDto dto) => MarketInstrument(
    id: dto.id,
    symbol: dto.symbol,
    companyName: dto.companyName,
    category: switch (dto.category) {
      'Equity' => MarketCategory.equity,
      'Future' => MarketCategory.futures,
      'Options' => MarketCategory.options,
      final category => throw TradingDataException(
        'Unsupported market category: $category.',
      ),
    },
    exchange: TradeExchange.parse(dto.exchange),
    ltp: dto.ltp,
    change: dto.change,
    changePercent: dto.changePercent,
    previousClose: dto.previousClose,
    tickSize: dto.tickSize,
    volume: dto.volume,
    tags: List<String>.unmodifiable(dto.tags),
    expiryDate: dto.expiryDate,
    strikePrice: dto.strikePrice,
    optionType: dto.optionType,
    underlyingSymbol: dto.underlyingSymbol,
  );
}
