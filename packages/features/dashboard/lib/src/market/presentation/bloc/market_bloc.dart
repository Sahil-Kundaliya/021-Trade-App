import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_instrument.dart';
import '../../domain/entities/market_subcategory.dart';
import '../../domain/repositories/market_repository.dart';
import 'market_event.dart';
import 'market_state.dart';

@injectable
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(this._repository, this._livePrices) : super(const MarketState()) {
    on<MarketStarted>(_load);
    on<MarketRetryRequested>(_load);
    on<MarketCategoryChanged>(_changeCategory);
    on<MarketSubcategoryChanged>(_changeSubcategory);
    on<MarketLivePricesReceived>(_applyLivePrices);
  }

  final MarketRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _load(MarketEvent event, Emitter<MarketState> emit) async {
    emit(state.copyWith(status: MarketStatus.loading, clearError: true));
    try {
      final funds = List<MarketInstrument>.unmodifiable(
        await _repository.getFunds(),
      );
      if (funds.isEmpty) {
        emit(state.copyWith(status: MarketStatus.empty, allFunds: funds));
        return;
      }
      emit(
        state.copyWith(
          status: MarketStatus.loaded,
          allFunds: funds,
          visibleFunds: _filter(
            funds,
            state.selectedCategory,
            state.selectedSubcategory,
          ),
        ),
      );
      _watch(state.visibleFunds);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: MarketStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _changeCategory(MarketCategoryChanged event, Emitter<MarketState> emit) {
    if (state.status != MarketStatus.loaded ||
        event.category == state.selectedCategory) {
      return;
    }
    final subcategory = event.category.subcategories.first;
    emit(
      state.copyWith(
        selectedCategory: event.category,
        selectedSubcategory: subcategory,
        visibleFunds: _filter(state.allFunds, event.category, subcategory),
      ),
    );
    _watch(state.visibleFunds);
  }

  void _changeSubcategory(
    MarketSubcategoryChanged event,
    Emitter<MarketState> emit,
  ) {
    if (state.status != MarketStatus.loaded ||
        event.subcategory == state.selectedSubcategory ||
        !state.selectedCategory.subcategories.contains(event.subcategory)) {
      return;
    }
    emit(
      state.copyWith(
        selectedSubcategory: event.subcategory,
        visibleFunds: _filter(
          state.allFunds,
          state.selectedCategory,
          event.subcategory,
        ),
      ),
    );
    _watch(state.visibleFunds);
  }

  void _watch(List<MarketInstrument> funds) {
    final seeds = funds.map(
      (fund) => LiveInstrumentSeed.fromPrices(
        instrumentId: fund.id,
        symbol: fund.symbol,
        ltp: fund.ltp,
        previousClose: fund.previousClose,
        tickSize: fund.tickSize,
      ),
    );
    final lease = _lease;
    if (lease == null) {
      final acquired = _livePrices.acquire(instruments: seeds);
      _lease = acquired;
      _liveSubscription = acquired.stream.listen(
        (batch) => add(MarketLivePricesReceived(batch)),
      );
    } else {
      unawaited(lease.update(seeds));
    }
  }

  void _applyLivePrices(
    MarketLivePricesReceived event,
    Emitter<MarketState> emit,
  ) {
    if (state.status != MarketStatus.loaded) return;
    final ticks = {
      for (final tick in event.batch.updates) tick.instrumentId: tick,
    };
    final visible = state.visibleFunds
        .map(
          (fund) => ticks[fund.id] == null
              ? fund
              : fund.withLivePrice(ticks[fund.id]!),
        )
        .toList(growable: false);
    final byId = {for (final fund in visible) fund.id: fund};
    final all = state.allFunds
        .map((fund) => byId[fund.id] ?? fund)
        .toList(growable: false);
    emit(
      state.copyWith(
        allFunds: List.unmodifiable(all),
        visibleFunds: List.unmodifiable(visible),
      ),
    );
  }

  static List<MarketInstrument> _filter(
    List<MarketInstrument> allFunds,
    MarketCategory category,
    MarketSubcategory subcategory,
  ) {
    final categoryFunds = allFunds
        .where((fund) => fund.category == category)
        .toList(growable: false);
    if (subcategory == MarketSubcategory.callMovers ||
        subcategory == MarketSubcategory.putMovers) {
      final optionType = subcategory == MarketSubcategory.callMovers
          ? 'CE'
          : 'PE';
      final options =
          categoryFunds
              .where((fund) => fund.optionType == optionType)
              .toList(growable: true)
            ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
      return List<MarketInstrument>.unmodifiable(options.take(5));
    }

    final tag = switch (subcategory) {
      MarketSubcategory.topGainers => 'Top Gainer',
      MarketSubcategory.topLosers => 'Top Loser',
      MarketSubcategory.mostActive => 'Most Active',
      _ => '',
    };
    final tagged = categoryFunds
        .where((fund) => fund.tags.contains(tag))
        .toList(growable: true);
    final ranked = List<MarketInstrument>.of(categoryFunds);
    switch (subcategory) {
      case MarketSubcategory.topGainers:
        ranked.sort((a, b) => b.changePercent.compareTo(a.changePercent));
      case MarketSubcategory.topLosers:
        ranked.sort((a, b) => a.changePercent.compareTo(b.changePercent));
      case MarketSubcategory.mostActive:
        ranked.sort((a, b) => b.volume.compareTo(a.volume));
      case MarketSubcategory.callMovers || MarketSubcategory.putMovers:
        break;
    }
    final selected = <MarketInstrument>[...tagged];
    for (final fund in ranked) {
      if (selected.length == 5) break;
      if (!selected.any((item) => item.id == fund.id)) selected.add(fund);
    }
    return List<MarketInstrument>.unmodifiable(selected.take(5));
  }
}
