import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../../domain/repositories/heat_map_repository.dart';
import 'market_heat_map_event.dart';
import 'market_heat_map_state.dart';

@injectable
class MarketHeatMapBloc extends Bloc<MarketHeatMapEvent, MarketHeatMapState> {
  MarketHeatMapBloc(this._repository, this._livePrices)
    : super(const MarketHeatMapState()) {
    on<MarketHeatMapStarted>(_start);
    on<MarketHeatMapRetryRequested>(_retry);
    on<MarketHeatMapExchangeChanged>(_changeExchange);
    on<MarketHeatMapLivePricesReceived>(_applyLivePrices);
  }

  final HeatMapRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;
  int _loadGeneration = 0;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _start(
    MarketHeatMapStarted event,
    Emitter<MarketHeatMapState> emit,
  ) => _load(emit, event.exchange);

  Future<void> _retry(
    MarketHeatMapRetryRequested event,
    Emitter<MarketHeatMapState> emit,
  ) => _load(emit, state.exchange);

  Future<void> _changeExchange(
    MarketHeatMapExchangeChanged event,
    Emitter<MarketHeatMapState> emit,
  ) async {
    if (event.exchange == state.exchange &&
        state.status == MarketHeatMapStatus.loaded) {
      return;
    }
    await _load(
      emit,
      event.exchange,
      minimumLoadingTime: const Duration(milliseconds: 650),
    );
  }

  Future<void> _load(
    Emitter<MarketHeatMapState> emit,
    TradeExchange exchange, {
    Duration minimumLoadingTime = Duration.zero,
  }) async {
    final loadingStarted = DateTime.now();
    final generation = ++_loadGeneration;
    emit(
      state.copyWith(
        status: MarketHeatMapStatus.loading,
        exchange: exchange,
        clearError: true,
      ),
    );
    try {
      final loaded = await _repository.getEquityFunds(exchange: exchange);
      if (generation != _loadGeneration) return;
      final remaining =
          minimumLoadingTime - DateTime.now().difference(loadingStarted);
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      if (generation != _loadGeneration) return;
      final funds = List<HeatMapFund>.unmodifiable(loaded);
      final fundsByKey = <String, HeatMapFund>{
        for (final fund in funds) fund.marketKey: fund,
      };
      if (funds.isEmpty) {
        await _liveSubscription?.cancel();
        await _lease?.dispose();
        _liveSubscription = null;
        _lease = null;
        emit(
          state.copyWith(
            status: MarketHeatMapStatus.empty,
            funds: funds,
            fundsByKey: Map<String, HeatMapFund>.unmodifiable(fundsByKey),
            livePrices: const {},
            exchange: exchange,
          ),
        );
        return;
      }

      final livePrices = <String, LivePriceTick>{};
      for (final fund in funds) {
        final cached = _livePrices.latestFor(fund.marketKey);
        if (cached != null) livePrices[fund.marketKey] = cached;
      }
      emit(
        state.copyWith(
          status: MarketHeatMapStatus.loaded,
          funds: funds,
          fundsByKey: Map<String, HeatMapFund>.unmodifiable(fundsByKey),
          livePrices: Map<String, LivePriceTick>.unmodifiable(livePrices),
          exchange: exchange,
        ),
      );
      _watch(funds);
    } on Object catch (error) {
      if (generation != _loadGeneration) return;
      emit(
        state.copyWith(
          status: MarketHeatMapStatus.error,
          errorMessage: error.toString(),
          exchange: exchange,
        ),
      );
    }
  }

  void _watch(List<HeatMapFund> funds) {
    final seeds = funds.map(
      (fund) => LiveInstrumentSeed.fromPrices(
        marketKey: fund.marketKey,
        fundId: fund.fundId,
        exchange: fund.exchange,
        assetType: LiveMarketAssetType.equity,
        symbol: fund.symbol,
        ltp: fund.initialLtp,
        previousClose: fund.previousClose,
        tickSize: fund.tickSize,
      ),
    );
    final lease = _lease;
    if (lease == null) {
      final acquired = _livePrices.acquire(instruments: seeds);
      _lease = acquired;
      _liveSubscription = acquired.stream.listen(
        (batch) => add(MarketHeatMapLivePricesReceived(batch)),
      );
    } else {
      unawaited(lease.update(seeds));
    }
  }

  void _applyLivePrices(
    MarketHeatMapLivePricesReceived event,
    Emitter<MarketHeatMapState> emit,
  ) {
    if (state.status != MarketHeatMapStatus.loaded) return;
    final relevant = event.batch.updates.where(
      (tick) => state.fundsByKey.containsKey(tick.instrumentId),
    );
    final livePrices = LivePriceTick.merge(state.livePrices, relevant);
    if (identical(livePrices, state.livePrices)) return;
    emit(state.copyWith(livePrices: livePrices));
  }
}
