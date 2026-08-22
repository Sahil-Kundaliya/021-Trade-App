import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/watchlist.dart';
import '../../domain/entities/watchlist_fund.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../mappers/watchlist_mapper.dart';

@LazySingleton(as: WatchlistRepository)
final class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._watchlistApi, this._tradingApi);

  final WatchlistLocalApi _watchlistApi;
  final TradingLocalApi _tradingApi;

  @override
  Stream<void> get watchlistChanges => _watchlistApi.watchlistChanges;

  @override
  Future<List<Watchlist>> getWatchlists() async =>
      (await _watchlistApi.getWatchlists())
          .map(WatchlistMapper.toDomain)
          .toList(growable: false);

  @override
  Future<void> saveWatchlists(List<Watchlist> watchlists) =>
      _watchlistApi.saveWatchlists(
        watchlists.map(WatchlistMapper.toDto).toList(growable: false),
      );

  @override
  Future<List<WatchlistFund>> getAllFunds() async =>
      (await _tradingApi.getFunds())
          .map(WatchlistMapper.fundToDomain)
          .toList(growable: false);

  @override
  Future<List<WatchlistFund>> getFundsForWatchlist(Watchlist watchlist) async {
    final allFunds = await getAllFunds();
    final byId = <String, WatchlistFund>{
      for (final fund in allFunds) fund.id: fund,
    };
    return List<WatchlistFund>.unmodifiable(
      watchlist.fundIds.map((id) => byId[id]).whereType<WatchlistFund>(),
    );
  }
}
