import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/repositories/holdings_repository.dart';
import 'holdings_event.dart';
import 'holdings_sort.dart';
import 'holdings_state.dart';

@injectable
class HoldingsBloc extends Bloc<HoldingsEvent, HoldingsState> {
  HoldingsBloc(this._repository, this._livePrices)
    : super(const HoldingsState()) {
    on<HoldingsStarted>(_load);
    on<HoldingsRetryRequested>(_load);
    on<HoldingsSortChanged>(_changeSort);
    on<HoldingsLivePricesReceived>(_applyLivePrices);
    on<HoldingsPositionsReceived>(_positionsReceived);
    on<HoldingsCategoryChanged>(_categoryChanged);
  }

  final HoldingsRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;
  StreamSubscription<List<Holding>>? _positionSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _load(HoldingsEvent event, Emitter<HoldingsState> emit) async {
    if (state.status == HoldingsStatus.loading) return;
    emit(state.copyWith(status: HoldingsStatus.loading, clearError: true));
    try {
      _positionSubscription ??= _repository.holdingChanges.listen(
        (holdings) => add(HoldingsPositionsReceived(holdings)),
      );
      final loaded = await _repository.getHoldings();
      await _applyPositions(loaded, emit);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: HoldingsStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _positionsReceived(
    HoldingsPositionsReceived event,
    Emitter<HoldingsState> emit,
  ) => _applyPositions(event.holdings, emit);

  Future<void> _applyPositions(
    List<Holding> loaded,
    Emitter<HoldingsState> emit,
  ) async {
    final holdings = loaded
        .map((holding) {
          final cached = _livePrices.latestFor(holding.marketKey);
          return cached == null ? holding : holding.withLivePrice(cached);
        })
        .toList(growable: false);
    final livePrices = Map<String, LivePriceTick>.fromEntries(
      loaded.map((holding) {
        final tick = _livePrices.latestFor(holding.marketKey);
        return tick == null
            ? null
            : MapEntry<String, LivePriceTick>(holding.marketKey, tick);
      }).whereType<MapEntry<String, LivePriceTick>>(),
    );
    final categories = PortfolioCategory.values
        .where(
          (category) => holdings.any((holding) => holding.category == category),
        )
        .toList(growable: false);
    final selected = categories.contains(state.selectedCategory)
        ? state.selectedCategory
        : categories.firstOrNull;
    await _watch(holdings);
    if (holdings.isEmpty) {
      emit(
        state.copyWith(
          status: HoldingsStatus.empty,
          holdings: const [],
          availableCategories: const [],
          clearSelectedCategory: true,
        ),
      );
      return;
    }
    final sorted = _sorted(holdings, state.sort);
    emit(
      state.copyWith(
        status: HoldingsStatus.loaded,
        holdings: sorted,
        summary: _summary(sorted),
        availableCategories: categories,
        selectedCategory: selected,
        livePrices: Map<String, LivePriceTick>.unmodifiable(livePrices),
        clearError: true,
      ),
    );
  }

  void _categoryChanged(
    HoldingsCategoryChanged event,
    Emitter<HoldingsState> emit,
  ) {
    if (state.availableCategories.contains(event.category)) {
      emit(state.copyWith(selectedCategory: event.category));
    }
  }

  void _changeSort(HoldingsSortChanged event, Emitter<HoldingsState> emit) {
    if (state.status != HoldingsStatus.loaded || event.sort == state.sort) {
      return;
    }
    emit(
      state.copyWith(
        sort: event.sort,
        holdings: _sorted(state.holdings, event.sort),
      ),
    );
  }

  static List<Holding> _sorted(List<Holding> source, HoldingsSort sort) {
    final holdings = List<Holding>.of(source);
    holdings.sort(switch (sort) {
      HoldingsSort.pnlDescending => (a, b) => b.pnl.compareTo(a.pnl),
      HoldingsSort.pnlAscending => (a, b) => a.pnl.compareTo(b.pnl),
      HoldingsSort.symbolAscending => (a, b) => a.symbol.compareTo(b.symbol),
      HoldingsSort.symbolDescending => (a, b) => b.symbol.compareTo(a.symbol),
      HoldingsSort.currentValueDescending => (a, b) => b.currentValue.compareTo(
        a.currentValue,
      ),
      HoldingsSort.currentValueAscending => (a, b) => a.currentValue.compareTo(
        b.currentValue,
      ),
    });
    return List<Holding>.unmodifiable(holdings);
  }

  Future<void> _watch(List<Holding> holdings) async {
    final seeds = holdings.map(
      (holding) => LiveInstrumentSeed.fromPrices(
        marketKey: holding.marketKey,
        fundId: holding.fundId,
        exchange: holding.tradeExchange,
        assetType: switch (holding.instrumentType) {
          'FUTURE' => LiveMarketAssetType.future,
          'OPTION' => LiveMarketAssetType.option,
          _ => LiveMarketAssetType.equity,
        },
        symbol: holding.symbol,
        ltp: holding.ltp,
        previousClose: holding.previousClose,
        tickSize: holding.tickSize,
      ),
    );
    final lease = _lease;
    if (lease == null) {
      if (holdings.isEmpty) return;
      final acquired = _livePrices.acquire(instruments: seeds);
      _lease = acquired;
      _liveSubscription = acquired.stream.listen(
        (batch) => add(HoldingsLivePricesReceived(batch)),
      );
    } else {
      await lease.update(seeds);
    }
  }

  void _applyLivePrices(
    HoldingsLivePricesReceived event,
    Emitter<HoldingsState> emit,
  ) {
    if (state.status != HoldingsStatus.loaded) return;
    final ticks = {
      for (final tick in event.batch.updates) tick.instrumentId: tick,
    };
    var changed = false;
    final holdings = <Holding>[];
    for (final holding in state.holdings) {
      final tick = ticks[holding.marketKey];
      if (tick == null) {
        holdings.add(holding);
        continue;
      }
      changed = true;
      holdings.add(holding.withLivePrice(tick));
    }
    if (!changed) return;
    emit(
      state.copyWith(
        holdings: _sorted(holdings, state.sort),
        summary: _summary(holdings),
        livePrices: LivePriceTick.merge(
          state.livePrices,
          event.batch.updates.where(
            (tick) => state.holdings.any(
              (holding) => holding.marketKey == tick.instrumentId,
            ),
          ),
        ),
      ),
    );
  }

  static PortfolioSummary _summary(List<Holding> holdings) {
    final totalInvested = holdings.fold<double>(
      0,
      (sum, item) => sum + item.investedValue,
    );
    final currentValue = holdings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
    final pnl = currentValue - totalInvested;
    return PortfolioSummary(
      totalInvested: totalInvested,
      currentValue: currentValue,
      totalPnl: pnl,
      totalPnlPercent: totalInvested == 0 ? 0 : pnl / totalInvested * 100,
    );
  }
}
