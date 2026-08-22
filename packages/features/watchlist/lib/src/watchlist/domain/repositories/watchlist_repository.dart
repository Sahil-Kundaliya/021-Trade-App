import '../entities/watchlist.dart';
import '../entities/watchlist_fund.dart';

abstract interface class WatchlistRepository {
  Future<List<Watchlist>> getWatchlists();

  Future<void> saveWatchlists(List<Watchlist> watchlists);

  Future<List<WatchlistFund>> getAllFunds();

  Future<List<WatchlistFund>> getFundsForWatchlist(Watchlist watchlist);
}
