import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/available_watchlist.dart';
import '../../domain/repositories/fund_watchlist_repository.dart';

@LazySingleton(as: FundWatchlistRepository)
final class FundWatchlistRepositoryImpl implements FundWatchlistRepository {
  const FundWatchlistRepositoryImpl(this._api);
  final WatchlistLocalApi _api;

  @override
  Future<List<AvailableWatchlist>> getAvailableWatchlists() async =>
      (await _api.getWatchlists()).map(_toDomain).toList(growable: false);

  @override
  Future<void> addFundToWatchlist({
    required String watchlistId,
    required String fundId,
  }) async {
    final watchlists = await _api.getWatchlists();
    final index = watchlists.indexWhere((item) => item.id == watchlistId);
    if (index < 0) throw StateError('Selected watchlist no longer exists.');
    final selected = watchlists[index];
    if (selected.fundIds.contains(fundId)) {
      throw FundAlreadyInWatchlistException(selected.name);
    }
    final updated = List<WatchlistDto>.of(watchlists);
    updated[index] = WatchlistDto(
      id: selected.id,
      name: selected.name,
      fundIds: [...selected.fundIds, fundId],
      createdAt: selected.createdAt,
      updatedAt: DateTime.now(),
    );
    await _api.saveWatchlists(updated);
  }

  @override
  Future<void> removeFundFromWatchlist({
    required String watchlistId,
    required String fundId,
  }) async {
    final watchlists = await _api.getWatchlists();
    final index = watchlists.indexWhere((item) => item.id == watchlistId);
    if (index < 0) throw StateError('Selected watchlist no longer exists.');
    final selected = watchlists[index];
    if (!selected.fundIds.contains(fundId)) return;
    final updated = List<WatchlistDto>.of(watchlists);
    updated[index] = WatchlistDto(
      id: selected.id,
      name: selected.name,
      fundIds: selected.fundIds
          .where((id) => id != fundId)
          .toList(growable: false),
      createdAt: selected.createdAt,
      updatedAt: DateTime.now(),
    );
    await _api.saveWatchlists(updated);
  }

  static AvailableWatchlist _toDomain(WatchlistDto dto) =>
      AvailableWatchlist(id: dto.id, name: dto.name, fundIds: dto.fundIds);
}
