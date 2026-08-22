import '../entities/available_watchlist.dart';

abstract interface class FundWatchlistRepository {
  Future<List<AvailableWatchlist>> getAvailableWatchlists();
  Future<void> addFundToWatchlist({
    required String watchlistId,
    required String fundId,
  });
}

class FundAlreadyInWatchlistException implements Exception {
  const FundAlreadyInWatchlistException(this.watchlistName);
  final String watchlistName;
}
