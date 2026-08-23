import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/watchlist.dart';
import '../../domain/entities/watchlist_fund.dart';
import '../../domain/repositories/watchlist_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

@injectable
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc(this._repository, [this._livePrices])
    : super(WatchlistState()) {
    on<WatchlistStarted>(_load);
    on<WatchlistRetryRequested>(_load);
    on<WatchlistDataChanged>(_refresh);
    on<WatchlistSelected>(_select);
    on<WatchlistCreateRequested>(_create);
    on<WatchlistRenameRequested>(_rename);
    on<WatchlistDeleteRequested>(_delete);
    on<WatchlistFundAddRequested>(_addFund);
    on<WatchlistFundRemoveRequested>(_removeFund);
    on<WatchlistFundsReorderRequested>(_reorderFunds);
    on<WatchlistsReorderRequested>(_reorderWatchlists);
    on<WatchlistLivePricesReceived>(_applyLivePrices);
    _watchlistChangesSubscription = _repository.watchlistChanges.listen((_) {
      if (!isClosed && !state.isSaving) add(const WatchlistDataChanged());
    });
  }

  static const maximumWatchlists = 5;
  static const maximumNameLength = 30;
  static const defaultWatchlistId = 'watchlist_default';

  final WatchlistRepository _repository;
  final LivePriceStreamManager? _livePrices;
  late final StreamSubscription<void> _watchlistChangesSubscription;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;

  @override
  Future<void> close() async {
    await _watchlistChangesSubscription.cancel();
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _load(WatchlistEvent event, Emitter<WatchlistState> emit) async {
    if (state.status == WatchlistStatus.loading) return;
    emit(state.copyWith(status: WatchlistStatus.loading, clearError: true));
    try {
      final watchlistsFuture = _repository.getWatchlists();
      final fundsFuture = _repository.getAllFunds();
      final watchlists = await watchlistsFuture;
      final funds = await fundsFuture;
      if (watchlists.isEmpty) {
        emit(WatchlistState(status: WatchlistStatus.empty, allFunds: funds));
        return;
      }
      final selected = watchlists.any((item) => item.id == defaultWatchlistId)
          ? defaultWatchlistId
          : watchlists.first.id;
      emit(
        WatchlistState(
          status: WatchlistStatus.loaded,
          watchlists: watchlists,
          selectedWatchlistId: selected,
          allFunds: funds,
          visibleFunds: _resolve(watchlists, selected, funds),
        ),
      );
      _watch(state.visibleFunds);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _refresh(
    WatchlistDataChanged event,
    Emitter<WatchlistState> emit,
  ) async {
    if (state.status != WatchlistStatus.loaded || state.isSaving) return;
    try {
      final watchlists = await _repository.getWatchlists();
      final previousSelected = state.selectedWatchlistId;
      final previousKeys = state.visibleFunds.map((fund) => fund.marketKey);
      final selected = watchlists.any((item) => item.id == previousSelected)
          ? previousSelected!
          : defaultWatchlistId;
      final visible = _resolve(watchlists, selected, state.allFunds);
      emit(
        state.copyWith(
          watchlists: watchlists,
          selectedWatchlistId: selected,
          visibleFunds: visible,
          clearMessage: true,
          clearError: true,
        ),
      );
      if (!_sameKeys(previousKeys, visible.map((fund) => fund.marketKey))) {
        _watch(state.visibleFunds);
      }
    } on Object catch (error) {
      emit(
        state.copyWith(
          message: 'Unable to refresh watchlists.',
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _select(WatchlistSelected event, Emitter<WatchlistState> emit) {
    if (state.status != WatchlistStatus.loaded ||
        !state.watchlists.any((item) => item.id == event.watchlistId)) {
      return;
    }
    emit(
      state.copyWith(
        selectedWatchlistId: event.watchlistId,
        visibleFunds: _resolve(
          state.watchlists,
          event.watchlistId,
          state.allFunds,
        ),
        clearMessage: true,
      ),
    );
    _watch(state.visibleFunds);
  }

  Future<void> _create(
    WatchlistCreateRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final name = event.name.trim();
    if (state.watchlists.length >= maximumWatchlists) {
      _reject(emit, 'A maximum of 5 watchlists is allowed.');
      return;
    }
    if (name.isEmpty || name.length > maximumNameLength || _hasName(name)) {
      _reject(
        emit,
        name.isEmpty
            ? 'Watchlist name is required.'
            : name.length > maximumNameLength
            ? 'Watchlist names can contain at most 30 characters.'
            : 'A watchlist with this name already exists.',
      );
      return;
    }
    final now = DateTime.now();
    var id = 'watchlist_${now.microsecondsSinceEpoch}';
    while (state.watchlists.any((item) => item.id == id)) {
      id = '${id}_new';
    }
    final next = <Watchlist>[
      ...state.watchlists,
      Watchlist(
        id: id,
        name: name,
        fundIds: const [],
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await _save(next, emit, selectedId: id);
  }

  Future<void> _rename(
    WatchlistRenameRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final name = event.newName.trim();
    final index = state.watchlists.indexWhere(
      (item) => item.id == event.watchlistId,
    );
    if (index < 0 ||
        name.isEmpty ||
        name.length > maximumNameLength ||
        _hasName(name, exceptId: event.watchlistId)) {
      _reject(
        emit,
        index < 0
            ? 'Watchlist not found.'
            : name.isEmpty
            ? 'Watchlist name is required.'
            : name.length > maximumNameLength
            ? 'Watchlist names can contain at most 30 characters.'
            : 'A watchlist with this name already exists.',
      );
      return;
    }
    if (state.watchlists[index].name == name) return;
    final next = List<Watchlist>.of(state.watchlists);
    next[index] = next[index].copyWith(name: name, updatedAt: DateTime.now());
    await _save(next, emit);
  }

  Future<void> _delete(
    WatchlistDeleteRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    if (event.watchlistId == defaultWatchlistId) {
      _reject(emit, 'The Default watchlist cannot be deleted.');
      return;
    }
    if (!state.watchlists.any((item) => item.id == event.watchlistId)) {
      _reject(emit, 'Watchlist not found.');
      return;
    }
    final next = state.watchlists
        .where((item) => item.id != event.watchlistId)
        .toList();
    final selectedId = state.selectedWatchlistId == event.watchlistId
        ? (next.any((item) => item.id == defaultWatchlistId)
              ? defaultWatchlistId
              : next.first.id)
        : state.selectedWatchlistId;
    await _save(next, emit, selectedId: selectedId);
  }

  Future<void> _addFund(
    WatchlistFundAddRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final index = state.watchlists.indexWhere(
      (item) => item.id == event.watchlistId,
    );
    if (index < 0 || !state.allFunds.any((fund) => fund.id == event.fundId)) {
      _reject(emit, index < 0 ? 'Watchlist not found.' : 'Fund not found.');
      return;
    }
    final target = state.watchlists[index];
    if (target.fundIds.contains(event.fundId)) {
      _reject(emit, 'This fund is already in the watchlist.');
      return;
    }
    final next = List<Watchlist>.of(state.watchlists);
    next[index] = target.copyWith(
      fundIds: <String>[...target.fundIds, event.fundId],
      updatedAt: DateTime.now(),
    );
    await _save(next, emit);
  }

  Future<void> _removeFund(
    WatchlistFundRemoveRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final index = state.watchlists.indexWhere(
      (item) => item.id == event.watchlistId,
    );
    if (index < 0) {
      _reject(emit, 'Watchlist not found.');
      return;
    }
    final target = state.watchlists[index];
    if (!target.fundIds.contains(event.fundId)) return;
    final next = List<Watchlist>.of(state.watchlists);
    next[index] = target.copyWith(
      fundIds: target.fundIds.where((id) => id != event.fundId).toList(),
      updatedAt: DateTime.now(),
    );
    await _save(next, emit);
  }

  Future<void> _reorderFunds(
    WatchlistFundsReorderRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final index = state.watchlists.indexWhere(
      (item) => item.id == event.watchlistId,
    );
    if (index < 0) {
      _reject(emit, 'Watchlist not found.');
      return;
    }
    final target = state.watchlists[index];
    if (event.oldIndex < 0 ||
        event.oldIndex >= target.fundIds.length ||
        event.newIndex < 0 ||
        event.newIndex > target.fundIds.length) {
      _reject(emit, 'Invalid fund order.');
      return;
    }
    final fundIds = List<String>.of(target.fundIds);
    var insertionIndex = event.newIndex;
    if (insertionIndex > event.oldIndex) insertionIndex -= 1;
    final fundId = fundIds.removeAt(event.oldIndex);
    fundIds.insert(insertionIndex, fundId);
    final next = List<Watchlist>.of(state.watchlists);
    next[index] = target.copyWith(fundIds: fundIds, updatedAt: DateTime.now());
    await _save(next, emit);
  }

  Future<void> _reorderWatchlists(
    WatchlistsReorderRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!_canWrite(emit)) return;
    final pinned = <Watchlist>[];
    final userWatchlists = <Watchlist>[];
    for (final watchlist in state.watchlists) {
      if (watchlist.id == defaultWatchlistId) {
        pinned.add(watchlist);
      } else {
        userWatchlists.add(watchlist);
      }
    }
    if (pinned.length != 1) {
      _reject(emit, 'Unable to reorder watchlists.');
      return;
    }
    if (event.oldIndex < 0 ||
        event.oldIndex >= userWatchlists.length ||
        event.newIndex < 0 ||
        event.newIndex > userWatchlists.length) {
      _reject(emit, 'Unable to reorder watchlists.');
      return;
    }
    var insertionIndex = event.newIndex;
    if (insertionIndex > event.oldIndex) insertionIndex -= 1;
    if (insertionIndex == event.oldIndex) return;
    final moved = userWatchlists.removeAt(event.oldIndex);
    userWatchlists.insert(insertionIndex, moved);
    final next = <Watchlist>[...pinned, ...userWatchlists];
    await _save(
      next,
      emit,
      failureMessage: 'Unable to reorder watchlists.',
      resubscribe: false,
    );
  }

  bool _canWrite(Emitter<WatchlistState> emit) {
    if (state.status != WatchlistStatus.loaded || state.isSaving) return false;
    return true;
  }

  bool _hasName(String name, {String? exceptId}) => state.watchlists.any(
    (item) =>
        item.id != exceptId &&
        item.name.trim().toLowerCase() == name.trim().toLowerCase(),
  );

  void _reject(Emitter<WatchlistState> emit, String message) {
    emit(state.copyWith(message: message, clearError: true));
  }

  Future<void> _save(
    List<Watchlist> next,
    Emitter<WatchlistState> emit, {
    String? selectedId,
    String failureMessage = 'Unable to save watchlist changes.',
    bool resubscribe = true,
  }) async {
    final previous = state;
    emit(
      previous.copyWith(isSaving: true, clearMessage: true, clearError: true),
    );
    try {
      await _repository.saveWatchlists(next);
      final selected =
          selectedId ?? previous.selectedWatchlistId ?? next.first.id;
      final visible = _resolve(next, selected, previous.allFunds);
      emit(
        WatchlistState(
          status: WatchlistStatus.loaded,
          watchlists: next,
          selectedWatchlistId: selected,
          allFunds: previous.allFunds,
          visibleFunds: visible,
          livePrices: previous.livePrices,
        ),
      );
      if (resubscribe) {
        final previousKeys = previous.visibleFunds.map((fund) => fund.marketKey);
        final nextKeys = visible.map((fund) => fund.marketKey);
        if (!_sameKeys(previousKeys, nextKeys)) {
          _watch(state.visibleFunds);
        }
      }
    } on Object catch (error) {
      emit(
        previous.copyWith(
          isSaving: false,
          message: failureMessage,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  static bool _sameKeys(Iterable<String> left, Iterable<String> right) {
    final first = left.toList(growable: false);
    final second = right.toList(growable: false);
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  static List<WatchlistFund> _resolve(
    List<Watchlist> watchlists,
    String selectedId,
    List<WatchlistFund> funds,
  ) {
    Watchlist? selected;
    for (final item in watchlists) {
      if (item.id == selectedId) {
        selected = item;
        break;
      }
    }
    if (selected == null) return const <WatchlistFund>[];
    final byId = <String, WatchlistFund>{
      for (final fund in funds) fund.id: fund,
    };
    return List<WatchlistFund>.unmodifiable(
      selected.fundIds.map((id) => byId[id]).whereType<WatchlistFund>(),
    );
  }

  void _watch(List<WatchlistFund> funds) {
    final manager = _livePrices;
    if (manager == null) return;
    final cached = funds
        .map((fund) => manager.latestFor(fund.marketKey))
        .whereType<LivePriceTick>()
        .toList(growable: false);
    if (cached.isNotEmpty) {
      final sequence = cached
          .map((tick) => tick.sequence)
          .reduce((a, b) => a > b ? a : b);
      add(
        WatchlistLivePricesReceived(
          LivePriceBatch(
            sequence: sequence,
            timestamp: cached.last.timestamp,
            updates: cached,
          ),
        ),
      );
    }
    final seeds = funds.map(
      (fund) => LiveInstrumentSeed.fromPrices(
        marketKey: fund.marketKey,
        fundId: fund.id,
        exchange: fund.tradeExchange,
        assetType: switch (fund.category) {
          'Future' => LiveMarketAssetType.future,
          'Options' => LiveMarketAssetType.option,
          _ => LiveMarketAssetType.equity,
        },
        symbol: fund.symbol,
        ltp: fund.ltp,
        previousClose: fund.previousClose,
        tickSize: fund.tickSize,
      ),
    );
    final lease = _lease;
    if (lease == null) {
      final acquired = manager.acquire(instruments: seeds);
      _lease = acquired;
      _liveSubscription = acquired.stream.listen(
        (batch) => add(WatchlistLivePricesReceived(batch)),
      );
    } else {
      unawaited(lease.update(seeds));
    }
  }

  void _applyLivePrices(
    WatchlistLivePricesReceived event,
    Emitter<WatchlistState> emit,
  ) {
    if (state.status != WatchlistStatus.loaded) return;
    final next = LivePriceTick.merge(state.livePrices, event.batch.updates);
    if (identical(next, state.livePrices)) return;
    emit(state.copyWith(livePrices: next));
  }
}
