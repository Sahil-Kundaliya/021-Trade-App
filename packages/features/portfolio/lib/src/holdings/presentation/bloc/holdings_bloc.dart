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
  }

  final HoldingsRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _load(HoldingsEvent event, Emitter<HoldingsState> emit) async {
    emit(state.copyWith(status: HoldingsStatus.loading, clearError: true));
    try {
      final holdings = await _repository.getHoldings();
      if (holdings.isEmpty) {
        emit(state.copyWith(status: HoldingsStatus.empty, holdings: const []));
        return;
      }
      final totalInvested = holdings.fold<double>(
        0,
        (total, holding) => total + holding.investedValue,
      );
      final currentValue = holdings.fold<double>(
        0,
        (total, holding) => total + holding.currentValue,
      );
      final totalPnl = currentValue - totalInvested;
      final summary = PortfolioSummary(
        totalInvested: totalInvested,
        currentValue: currentValue,
        totalPnl: totalPnl,
        totalPnlPercent: totalInvested == 0
            ? 0
            : totalPnl / totalInvested * 100,
      );
      emit(
        state.copyWith(
          status: HoldingsStatus.loaded,
          holdings: _sorted(holdings, state.sort),
          summary: summary,
        ),
      );
      _watch(holdings);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: HoldingsStatus.error,
          errorMessage: error.toString(),
        ),
      );
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

  void _watch(List<Holding> holdings) {
    final seeds = holdings.map(
      (holding) => LiveInstrumentSeed.fromPrices(
        instrumentId: holding.fundId,
        symbol: holding.symbol,
        ltp: holding.ltp,
        previousClose: holding.previousClose,
        tickSize: holding.tickSize,
      ),
    );
    final acquired = _livePrices.acquire(instruments: seeds);
    _lease = acquired;
    _liveSubscription = acquired.stream.listen(
      (batch) => add(HoldingsLivePricesReceived(batch)),
    );
  }

  void _applyLivePrices(
    HoldingsLivePricesReceived event,
    Emitter<HoldingsState> emit,
  ) {
    if (state.status != HoldingsStatus.loaded) return;
    final ticks = {
      for (final tick in event.batch.updates) tick.instrumentId: tick,
    };
    final holdings = state.holdings
        .map((holding) {
          final tick = ticks[holding.fundId];
          return tick == null ? holding : holding.withLivePrice(tick);
        })
        .toList(growable: false);
    final totalInvested = holdings.fold<double>(
      0,
      (sum, item) => sum + item.investedValue,
    );
    final currentValue = holdings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
    final pnl = currentValue - totalInvested;
    emit(
      state.copyWith(
        holdings: _sorted(holdings, state.sort),
        summary: PortfolioSummary(
          totalInvested: totalInvested,
          currentValue: currentValue,
          totalPnl: pnl,
          totalPnlPercent: totalInvested == 0 ? 0 : pnl / totalInvested * 100,
        ),
      ),
    );
  }
}
