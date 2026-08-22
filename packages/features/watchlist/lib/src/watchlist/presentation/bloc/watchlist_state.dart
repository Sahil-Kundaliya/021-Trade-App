import '../../domain/entities/watchlist.dart';
import '../../domain/entities/watchlist_fund.dart';

enum WatchlistStatus { initial, loading, loaded, empty, error }

class WatchlistState {
  WatchlistState({
    this.status = WatchlistStatus.initial,
    List<Watchlist> watchlists = const <Watchlist>[],
    this.selectedWatchlistId,
    List<WatchlistFund> allFunds = const <WatchlistFund>[],
    List<WatchlistFund> visibleFunds = const <WatchlistFund>[],
    this.isSaving = false,
    this.message,
    this.errorMessage,
  }) : watchlists = List<Watchlist>.unmodifiable(watchlists),
       allFunds = List<WatchlistFund>.unmodifiable(allFunds),
       visibleFunds = List<WatchlistFund>.unmodifiable(visibleFunds);

  final WatchlistStatus status;
  final List<Watchlist> watchlists;
  final String? selectedWatchlistId;
  final List<WatchlistFund> allFunds;
  final List<WatchlistFund> visibleFunds;
  final bool isSaving;
  final String? message;
  final String? errorMessage;

  Watchlist? get selectedWatchlist {
    for (final item in watchlists) {
      if (item.id == selectedWatchlistId) return item;
    }
    return null;
  }

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<Watchlist>? watchlists,
    String? selectedWatchlistId,
    List<WatchlistFund>? allFunds,
    List<WatchlistFund>? visibleFunds,
    bool? isSaving,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) => WatchlistState(
    status: status ?? this.status,
    watchlists: watchlists ?? this.watchlists,
    selectedWatchlistId: selectedWatchlistId ?? this.selectedWatchlistId,
    allFunds: allFunds ?? this.allFunds,
    visibleFunds: visibleFunds ?? this.visibleFunds,
    isSaving: isSaving ?? this.isSaving,
    message: clearMessage ? null : message ?? this.message,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
