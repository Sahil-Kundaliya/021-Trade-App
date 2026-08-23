import 'package:core_data/core_data.dart';

import '../../domain/entities/watchlist.dart';
import '../../domain/entities/watchlist_fund.dart';

abstract final class WatchlistMapper {
  static Watchlist toDomain(WatchlistDto dto) => Watchlist(
    id: dto.id,
    name: dto.name,
    fundIds: dto.fundIds,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );

  static WatchlistDto toDto(Watchlist watchlist) => WatchlistDto(
    id: watchlist.id,
    name: watchlist.name,
    fundIds: watchlist.fundIds,
    createdAt: watchlist.createdAt,
    updatedAt: watchlist.updatedAt,
  );

  static WatchlistFund fundToDomain(FundDto dto) => WatchlistFund(
    id: dto.id,
    symbol: dto.symbol,
    companyName: dto.companyName,
    exchange: dto.exchange,
    category: dto.category,
    ltp: dto.ltp,
    change: dto.change,
    changePercent: dto.changePercent,
    previousClose: dto.previousClose,
    tickSize: dto.tickSize,
    tags: dto.tags,
  );
}
