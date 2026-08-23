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
    this._orderStore,
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
    on<FundOrdersChanged>(_onOrdersChanged);
    on<FundWatchlistsChanged>(_onWatchlistsChanged);
    if (_watchlistRepository is FundWatchlistChangeSource) {
      final source = _watchlistRepository as FundWatchlistChangeSource;
      _watchlistSubscription = source.watchlistChanges.listen((_) {
        if (!isClosed && !state.isAddingToWatchlist) {
          add(const FundWatchlistsChanged());
        }
      });
    }
    final orderStore = _orderStore;
    if (orderStore != null) {
      _orderSubscription = orderStore.changes.listen(
        (change) => add(FundOrdersChanged(change.orders)),
      );
    }
  }

  final FundRepository _fundRepository;
  final FundWatchlistRepository _watchlistRepository;
  final LivePriceStreamManager? _livePrices;
  final OrderStore? _orderStore;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;
  StreamSubscription<OrderBookChange>? _orderSubscription;
  StreamSubscription<void>? _watchlistSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _orderSubscription?.cancel();
    await _watchlistSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _onStarted(
    FundDetailsStarted event,
    Emitter<FundDetailsState> emit,
  ) async {
    emit(
      FundDetailsState(
        status: FundDetailsStatus.loading,
        fundId: event.fundId,
        exchange: event.exchange,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _fundRepository.getFundById(event.fundId, exchange: event.exchange),
        _watchlistRepository.getAvailableWatchlists(),
      ]);
      final fund = results[0] as FundDetails;
      final orders = await _orderStore?.getOrders() ?? const <OrderDto>[];
      final watchlists = results[1] as List<AvailableWatchlist>;
      final selectedWatchlistId = watchlists
          .where((watchlist) => watchlist.containsFund(fund.id))
          .firstOrNull
          ?.id;
      emit(
        state.copyWith(
          status: FundDetailsStatus.loaded,
          fund: fund.withRecentActivity(
            _activities(fund.id, event.exchange, orders),
          ),
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
    if (id != null) {
      add(FundDetailsStarted(fundId: id, exchange: state.exchange));
    }
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
    final cached = manager.latestFor(fund.marketKey);
    if (cached != null) {
      add(
        FundLivePricesReceived(
          LivePriceBatch(
            sequence: cached.sequence,
            timestamp: cached.timestamp,
            updates: <LivePriceTick>[cached],
          ),
        ),
      );
    }
    final seed = LiveInstrumentSeed.fromPrices(
      marketKey: fund.marketKey,
      fundId: fund.id,
      exchange: fund.exchange,
      assetType: switch (fund.instrumentType) {
        FundInstrumentType.equity => LiveMarketAssetType.equity,
        FundInstrumentType.future => LiveMarketAssetType.future,
        FundInstrumentType.option => LiveMarketAssetType.option,
      },
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
      if (tick.instrumentId == fund.marketKey) {
        emit(state.copyWith(fund: fund.withLivePrice(tick)));
        return;
      }
    }
  }

  void _onOrdersChanged(
    FundOrdersChanged event,
    Emitter<FundDetailsState> emit,
  ) {
    final fund = state.fund;
    if (fund == null) return;
    emit(
      state.copyWith(
        fund: fund.withRecentActivity(
          _activities(fund.id, fund.exchange, event.orders),
        ),
      ),
    );
  }

  Future<void> _onWatchlistsChanged(
    FundWatchlistsChanged event,
    Emitter<FundDetailsState> emit,
  ) async {
    if (state.status != FundDetailsStatus.loaded || state.isAddingToWatchlist) {
      return;
    }
    try {
      final watchlists = await _watchlistRepository.getAvailableWatchlists();
      final previousId = state.selectedWatchlistId;
      final selectedId = watchlists.any((item) => item.id == previousId)
          ? previousId
          : watchlists.firstOrNull?.id;
      emit(
        state.copyWith(
          availableWatchlists: watchlists,
          selectedWatchlistId: selectedId,
          clearSelectedWatchlist: selectedId == null,
        ),
      );
    } on Object {
      // Keep the last valid picker state if a background refresh fails.
    }
  }

  static List<FundActivity> _activities(
    String fundId,
    TradeExchange exchange,
    List<OrderDto> orders,
  ) {
    final matching =
        orders
            .where(
              (order) =>
                  order.fundId == fundId &&
                  TradeExchange.parse(order.exchange) == exchange,
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List<FundActivity>.unmodifiable(
      matching.take(5).map((order) {
        final side = order.side.toUpperCase();
        final status = switch (order.status) {
          'triggerPending' => 'TRIGGER PENDING',
          'partiallyFilled' => 'PARTIALLY FILLED',
          final value => value.toUpperCase(),
        };
        final description = switch (order.status) {
          'executed' =>
            '${order.side == 'buy' ? 'Bought' : 'Sold'} ${order.filledQuantity}\n'
                '₹${(order.averagePrice ?? order.ltp).toStringAsFixed(2)}',
          'triggerPending' =>
            '${order.quantity} Qty\nTrigger ₹${order.triggerPrice?.toStringAsFixed(2) ?? '—'}',
          _ when order.limitPrice != null =>
            '${order.quantity} Qty\nLimit ₹${order.limitPrice!.toStringAsFixed(2)}',
          _ => '${order.quantity} Qty',
        };
        return FundActivity(
          id: order.id,
          type: 'order',
          title: '$side · $status',
          description: description,
          timestamp: order.updatedAt,
        );
      }),
    );
  }
}
