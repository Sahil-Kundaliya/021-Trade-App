import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/searchable_fund.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository, this._livePrices) : super(const SearchState()) {
    on<SearchStarted>(_load);
    on<SearchRetryRequested>(_load);
    on<SearchQueryChanged>(_changeQuery);
    on<SearchCategoryChanged>(_changeCategory);
    on<SearchLivePricesReceived>(_applyLivePrices);
  }

  final SearchRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;
  Future<List<SearchableFund>>? _loadFuture;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _load(SearchEvent event, Emitter<SearchState> emit) async {
    if (state.status == SearchStatus.loading) return;
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      final loaded = await (_loadFuture ??= _repository.getFunds());
      final funds = List<SearchableFund>.unmodifiable(
        loaded.map((fund) {
          final cached = _livePrices.latestFor(fund.marketKey);
          return cached == null ? fund : fund.withLivePrice(cached);
        }),
      );
      final visible = _filter(funds, state.query, state.selectedCategory);
      emit(
        state.copyWith(
          status: SearchStatus.loaded,
          allFunds: funds,
          visibleFunds: visible,
        ),
      );
      _watch(visible);
    } on Object catch (error) {
      _loadFuture = null;
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _changeQuery(SearchQueryChanged event, Emitter<SearchState> emit) {
    if (state.status != SearchStatus.loaded) return;
    final visible = _filter(
      state.allFunds,
      event.query,
      state.selectedCategory,
    );
    emit(state.copyWith(query: event.query, visibleFunds: visible));
    _watch(visible);
  }

  void _changeCategory(SearchCategoryChanged event, Emitter<SearchState> emit) {
    if (state.status != SearchStatus.loaded ||
        event.category == state.selectedCategory) {
      return;
    }
    final visible = _filter(state.allFunds, state.query, event.category);
    emit(
      state.copyWith(selectedCategory: event.category, visibleFunds: visible),
    );
    _watch(visible);
  }

  void _watch(List<SearchableFund> funds) {
    final seeds = funds.map(
      (fund) => LiveInstrumentSeed.fromPrices(
        marketKey: fund.marketKey,
        fundId: fund.id,
        exchange: fund.exchange,
        assetType: switch (fund.category) {
          SearchCategory.equity => LiveMarketAssetType.equity,
          SearchCategory.future => LiveMarketAssetType.future,
          SearchCategory.options => LiveMarketAssetType.option,
          SearchCategory.all => LiveMarketAssetType.equity,
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
        (batch) => add(SearchLivePricesReceived(batch)),
      );
    } else {
      unawaited(lease.update(seeds));
    }
  }

  void _applyLivePrices(
    SearchLivePricesReceived event,
    Emitter<SearchState> emit,
  ) {
    if (state.status != SearchStatus.loaded) return;
    final ticks = {
      for (final tick in event.batch.updates) tick.instrumentId: tick,
    };
    final all = List<SearchableFund>.unmodifiable(
      state.allFunds.map(
        (fund) => ticks[fund.marketKey] == null
            ? fund
            : fund.withLivePrice(ticks[fund.marketKey]!),
      ),
    );
    emit(
      state.copyWith(
        allFunds: all,
        visibleFunds: _filter(all, state.query, state.selectedCategory),
      ),
    );
  }

  static List<SearchableFund> _filter(
    List<SearchableFund> funds,
    String query,
    SearchCategory category,
  ) {
    final normalized = query.trim().toLowerCase();
    final categoryFunds = funds
        .where(
          (fund) => category == SearchCategory.all || fund.category == category,
        )
        .toList(growable: false);
    if (normalized.length < 3) {
      if (category == SearchCategory.all) {
        final mixed =
            const [
              SearchCategory.equity,
              SearchCategory.future,
              SearchCategory.options,
            ].expand(
              (value) =>
                  categoryFunds.where((fund) => fund.category == value).take(1),
            );
        return List<SearchableFund>.unmodifiable(mixed);
      }
      return List<SearchableFund>.unmodifiable(categoryFunds.take(3));
    }

    int relevance(SearchableFund fund) {
      final symbol = fund.symbol.toLowerCase();
      final company = fund.companyName.toLowerCase();
      if (symbol == normalized) return 0;
      if (symbol.startsWith(normalized)) return 1;
      if (company.startsWith(normalized)) return 2;
      if (symbol.contains(normalized)) return 3;
      return 4;
    }

    final matches =
        categoryFunds
            .where(
              (fund) =>
                  fund.symbol.toLowerCase().contains(normalized) ||
                  fund.companyName.toLowerCase().contains(normalized),
            )
            .toList(growable: true)
          ..sort((a, b) {
            final rank = relevance(a).compareTo(relevance(b));
            if (rank != 0) return rank;
            final symbol = a.symbol.compareTo(b.symbol);
            if (symbol != 0) return symbol;
            return a.marketKey.compareTo(b.marketKey);
          });
    return List<SearchableFund>.unmodifiable(matches);
  }
}
