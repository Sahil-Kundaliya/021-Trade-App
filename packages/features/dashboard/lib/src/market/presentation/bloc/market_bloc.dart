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
    on<MarketExchangeChanged>(_changeExchange);
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
    if (state.status == MarketStatus.loading) return;
    emit(state.copyWith(status: MarketStatus.loading, clearError: true));
    try {
      final loaded = await _repository.getFunds();
      var funds = List<MarketInstrument>.unmodifiable(
        loaded.map((fund) {
          final cached = _livePrices.latestFor(fund.marketKey);
          return cached == null ? fund : fund.withLivePrice(cached);
        }),
      );
      funds = List<MarketInstrument>.unmodifiable(
        _applyDynamicTags(
          funds,
          state.selectedCategory,
          state.selectedExchange,
        ),
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
            state.selectedExchange,
          ),
        ),
      );
      _watch(
        _categoryFunds(funds, state.selectedCategory, state.selectedExchange),
      );
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
    final exchange = event.category == MarketCategory.equity
        ? state.selectedExchange
        : TradeExchange.nse;
    emit(
      state.copyWith(
        selectedCategory: event.category,
        selectedSubcategory: subcategory,
        selectedExchange: exchange,
        visibleFunds: _filter(
          state.allFunds,
          event.category,
          subcategory,
          exchange,
        ),
      ),
    );
    _watch(_categoryFunds(state.allFunds, event.category, exchange));
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
          state.selectedExchange,
        ),
      ),
    );
  }

  void _changeExchange(MarketExchangeChanged event, Emitter<MarketState> emit) {
    if (state.status != MarketStatus.loaded ||
        state.selectedCategory != MarketCategory.equity ||
        event.exchange == state.selectedExchange) {
      return;
    }
    final all = _applyDynamicTags(
      state.allFunds,
      state.selectedCategory,
      event.exchange,
    );
    emit(
      state.copyWith(
        allFunds: List.unmodifiable(all),
        selectedExchange: event.exchange,
        visibleFunds: _filter(
          all,
          state.selectedCategory,
          state.selectedSubcategory,
          event.exchange,
        ),
      ),
    );
    _watch(_categoryFunds(all, state.selectedCategory, event.exchange));
  }

  void _watch(List<MarketInstrument> funds) {
    final seeds = funds.map(
      (fund) => LiveInstrumentSeed.fromPrices(
        marketKey: fund.marketKey,
        fundId: fund.id,
        exchange: fund.exchange,
        assetType: switch (fund.category) {
          MarketCategory.equity => LiveMarketAssetType.equity,
          MarketCategory.futures => LiveMarketAssetType.future,
          MarketCategory.options => LiveMarketAssetType.option,
        },
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
    var all = state.allFunds
        .map(
          (fund) => ticks[fund.marketKey] == null
              ? fund
              : fund.withLivePrice(ticks[fund.marketKey]!),
        )
        .toList(growable: false);
    all = _applyDynamicTags(
      all,
      state.selectedCategory,
      state.selectedExchange,
    );
    emit(
      state.copyWith(
        allFunds: List.unmodifiable(all),
        visibleFunds: _filter(
          all,
          state.selectedCategory,
          state.selectedSubcategory,
          state.selectedExchange,
        ),
      ),
    );
  }

  static List<MarketInstrument> _categoryFunds(
    List<MarketInstrument> funds,
    MarketCategory category,
    TradeExchange exchange,
  ) => funds
      .where((fund) => fund.category == category && fund.exchange == exchange)
      .toList(growable: false);

  static List<MarketInstrument> _applyDynamicTags(
    List<MarketInstrument> funds,
    MarketCategory category,
    TradeExchange exchange,
  ) {
    final candidates = _categoryFunds(funds, category, exchange);
    final gainers = candidates.where((fund) => fund.changePercent > 0).toList()
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final losers = candidates.where((fund) => fund.changePercent < 0).toList()
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    final gainerIds = gainers.take(3).map((fund) => fund.marketKey).toSet();
    final loserIds = losers.take(3).map((fund) => fund.marketKey).toSet();
    return funds
        .map((fund) {
          if (fund.category != category || fund.exchange != exchange) {
            return fund;
          }
          final tags = fund.tags
              .where((tag) => tag != 'Top Gainer' && tag != 'Top Loser')
              .toList(growable: true);
          if (gainerIds.contains(fund.marketKey)) tags.add('Top Gainer');
          if (loserIds.contains(fund.marketKey)) tags.add('Top Loser');
          return fund.withTags(tags);
        })
        .toList(growable: false);
  }

  static List<MarketInstrument> _filter(
    List<MarketInstrument> allFunds,
    MarketCategory category,
    MarketSubcategory subcategory,
    TradeExchange exchange,
  ) {
    final categoryFunds = allFunds
        .where((fund) => fund.category == category && fund.exchange == exchange)
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

    final ranked = List<MarketInstrument>.of(categoryFunds);
    switch (subcategory) {
      case MarketSubcategory.topGainers:
        final positive = ranked
            .where((fund) => fund.changePercent > 0)
            .toList(growable: false);
        if (positive.isNotEmpty) {
          ranked
            ..clear()
            ..addAll(positive);
        }
        ranked.sort((a, b) => b.changePercent.compareTo(a.changePercent));
      case MarketSubcategory.topLosers:
        final negative = ranked
            .where((fund) => fund.changePercent < 0)
            .toList(growable: false);
        if (negative.isNotEmpty) {
          ranked
            ..clear()
            ..addAll(negative);
        }
        ranked.sort((a, b) => a.changePercent.compareTo(b.changePercent));
      case MarketSubcategory.mostActive:
        ranked.sort((a, b) => b.volume.compareTo(a.volume));
      case MarketSubcategory.callMovers || MarketSubcategory.putMovers:
        break;
    }
    return List<MarketInstrument>.unmodifiable(ranked.take(5));
  }
}
