import '../models/watchlist_dto.dart';

abstract interface class WatchlistLocalApi {
  Future<List<WatchlistDto>> getWatchlists();

  Future<void> saveWatchlists(List<WatchlistDto> watchlists);
}
