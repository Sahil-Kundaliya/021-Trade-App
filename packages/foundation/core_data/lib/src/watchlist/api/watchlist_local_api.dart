import '../models/watchlist_dto.dart';

abstract interface class WatchlistLocalApi {
  Stream<void> get watchlistChanges;

  Future<List<WatchlistDto>> getWatchlists();

  Future<void> saveWatchlists(List<WatchlistDto> watchlists);
}
