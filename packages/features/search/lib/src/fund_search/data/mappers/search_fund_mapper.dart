import 'package:core_data/core_data.dart';

import '../../domain/entities/searchable_fund.dart';

abstract final class SearchFundMapper {
  static SearchableFund toDomain(FundDto dto) => SearchableFund(
    id: dto.id,
    symbol: dto.symbol,
    companyName: dto.companyName,
    category: switch (dto.category) {
      'Equity' => SearchCategory.equity,
      'Future' => SearchCategory.future,
      'Options' => SearchCategory.options,
      final category => throw TradingDataException(
        'Unsupported search category: $category.',
      ),
    },
    instrumentType: dto.instrumentType,
    exchange: TradeExchange.parse(dto.exchange),
    ltp: dto.ltp,
    change: dto.change,
    changePercent: dto.changePercent,
    previousClose: dto.previousClose,
    tickSize: dto.tickSize,
    tags: List<String>.unmodifiable(dto.tags),
  );
}
