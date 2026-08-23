import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/fund_repository.dart';
import '../../domain/repositories/fund_watchlist_repository.dart';
import '../../domain/entities/available_watchlist.dart';
import '../../domain/entities/fund_details.dart';
import 'fund_details_event.dart';
import 'fund_details_state.dart';

@injectable
class FundDetailsBloc extends Bloc<FundDetailsEvent, FundDetailsState> {
  FundDetailsBloc(
    this._fundRepository,
    this._watchlistRepository, [
    this._livePrices,
  ]) : super(const FundDetailsState()) {
    on<FundDetailsStarted>(_onStarted);
    on<FundDetailsRetryRequested>(_onRetry);
    on<FundHistoryPeriodChanged>(_onHistoryChanged);
    on<FundAddToWatchlistOpened>(_onPickerOpened);
    on<FundAddToWatchlistDismissed>(_onPickerDismissed);
    on<FundWatchlistSelected>(_onWatchlistSelected);
    on<FundAddToWatchlistRequested>(_onAddRequested);
    on<FundRemoveFromWatchlistRequested>(_onRemoveRequested);
    on<FundLivePricesReceived>(_onLivePrices);
  }

  final FundRepository _fundRepository;
  final FundWatchlistRepository _watchlistRepository;
  final LivePriceStreamManager? _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _onStarted(
    FundDetailsStarted event,
    Emitter<FundDetailsState> emit,
  ) async {
    emit(
      FundDetailsState(status: FundDetailsStatus.loading, fundId: event.fundId),
    );
    try {
      final results = await Future.wait<Object>([
        _fundRepository.getFundById(event.fundId),
        _watchlistRepository.getAvailableWatchlists(),
      ]);
      final fund = results[0] as FundDetails;
      final watchlists = results[1] as List<AvailableWatchlist>;
      final selectedWatchlistId = watchlists
          .where((watchlist) => watchlist.containsFund(fund.id))
          .firstOrNull
          ?.id;
      emit(
        state.copyWith(
          status: FundDetailsStatus.loaded,
          fund: fund,
          availableWatchlists: watchlists,
          selectedWatchlistId:
              selectedWatchlistId ?? watchlists.firstOrNull?.id,
          clearError: true,
        ),
      );
      _watch(fund);
    } on Object {
      emit(
        state.copyWith(
          status: FundDetailsStatus.error,
          errorMessage: 'Unable to load fund details.',
        ),
      );
    }
  }

  void _onRetry(
    FundDetailsRetryRequested event,
    Emitter<FundDetailsState> emit,
  ) {
    final id = state.fundId;
    if (id != null) add(FundDetailsStarted(fundId: id));
  }

  void _onHistoryChanged(
    FundHistoryPeriodChanged event,
    Emitter<FundDetailsState> emit,
  ) {
    if (state.status == FundDetailsStatus.loaded) {
      emit(state.copyWith(selectedHistoryPeriod: event.period));
    }
  }

  void _onPickerOpened(
    FundAddToWatchlistOpened event,
    Emitter<FundDetailsState> emit,
  ) {
    final firstId = state.availableWatchlists.isEmpty
        ? null
        : state.availableWatchlists.first.id;
    emit(
      state.copyWith(
        isWatchlistPickerOpen: true,
        selectedWatchlistId: state.selectedWatchlistId ?? firstId,
        clearMessage: true,
      ),
    );
  }

  void _onPickerDismissed(
    FundAddToWatchlistDismissed event,
    Emitter<FundDetailsState> emit,
  ) => emit(state.copyWith(isWatchlistPickerOpen: false, clearMessage: true));

  void _onWatchlistSelected(
    FundWatchlistSelected event,
    Emitter<FundDetailsState> emit,
  ) => emit(
    state.copyWith(selectedWatchlistId: event.watchlistId, clearMessage: true),
  );

  Future<void> _onAddRequested(
    FundAddToWatchlistRequested event,
    Emitter<FundDetailsState> emit,
  ) async {
    final fund = state.fund;
    final watchlistId = state.selectedWatchlistId;
    if (fund == null || watchlistId == null || state.isAddingToWatchlist) {
      return;
    }
    final selected = state.availableWatchlists
        .where((item) => item.id == watchlistId)
        .firstOrNull;
    if (selected == null) return;
    if (selected.containsFund(fund.id)) {
      emit(
        state.copyWith(
          message: 'Already in ${selected.name}',
          messageVersion: state.messageVersion + 1,
        ),
      );
      return;
    }
    emit(state.copyWith(isAddingToWatchlist: true, clearMessage: true));
    try {
      await _watchlistRepository.addFundToWatchlist(
        watchlistId: watchlistId,
        fundId: fund.id,
      );
      final updated = state.availableWatchlists
          .map((item) => item.id == watchlistId ? item.withFund(fund.id) : item)
          .toList(growable: false);
      emit(
        state.copyWith(
          availableWatchlists: updated,
          isAddingToWatchlist: false,
          isWatchlistPickerOpen: false,
          message: 'Added to ${selected.name}',
          messageVersion: state.messageVersion + 1,
        ),
      );
    } on FundAlreadyInWatchlistException catch (error) {
      emit(
        state.copyWith(
          isAddingToWatchlist: false,
          message: 'Already in ${error.watchlistName}',
          messageVersion: state.messageVersion + 1,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isAddingToWatchlist: false,
          message: 'Unable to add to watchlist.',
          messageVersion: state.messageVersion + 1,
        ),
      );
    }
  }

  Future<void> _onRemoveRequested(
    FundRemoveFromWatchlistRequested event,
    Emitter<FundDetailsState> emit,
  ) async {
    final fund = state.fund;
    final selected = state.watchlistContainingFund;
    if (fund == null || selected == null || state.isAddingToWatchlist) return;
    emit(state.copyWith(isAddingToWatchlist: true, clearMessage: true));
    try {
      await _watchlistRepository.removeFundFromWatchlist(
        watchlistId: selected.id,
        fundId: fund.id,
      );
      final updated = state.availableWatchlists
          .map(
            (item) => item.id == selected.id ? item.withoutFund(fund.id) : item,
          )
          .toList(growable: false);
      final nextContaining = updated
          .where((watchlist) => watchlist.containsFund(fund.id))
          .firstOrNull;
      emit(
        state.copyWith(
          availableWatchlists: updated,
          selectedWatchlistId: nextContaining?.id ?? selected.id,
          isAddingToWatchlist: false,
          isWatchlistPickerOpen: false,
          message: 'Removed from ${selected.name}',
          messageVersion: state.messageVersion + 1,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isAddingToWatchlist: false,
          message: 'Unable to remove from watchlist.',
          messageVersion: state.messageVersion + 1,
        ),
      );
    }
  }

  void _watch(FundDetails fund) {
    final manager = _livePrices;
    if (manager == null) return;
    final seed = LiveInstrumentSeed.fromPrices(
      instrumentId: fund.id,
      symbol: fund.symbol,
      ltp: fund.ltp,
      previousClose: fund.previousClose,
      tickSize: fund.tickSize,
    );
    final acquired = manager.acquire(instruments: [seed]);
    _lease = acquired;
    _liveSubscription = acquired.stream.listen(
      (batch) => add(FundLivePricesReceived(batch)),
    );
  }

  void _onLivePrices(
    FundLivePricesReceived event,
    Emitter<FundDetailsState> emit,
  ) {
    final fund = state.fund;
    if (fund == null) return;
    for (final tick in event.batch.updates) {
      if (tick.instrumentId == fund.id) {
        emit(state.copyWith(fund: fund.withLivePrice(tick)));
        return;
      }
    }
  }
}
