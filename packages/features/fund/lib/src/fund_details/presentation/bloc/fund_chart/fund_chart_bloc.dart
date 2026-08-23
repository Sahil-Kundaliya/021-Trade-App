import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/price_candle.dart';
import '../../../domain/repositories/fund_chart_repository.dart';
import 'fund_chart_state.dart';

@injectable
class FundChartBloc extends Bloc<FundChartEvent, FundChartState> {
  FundChartBloc(this._repository, this._livePrices)
    : super(const FundChartState()) {
    on<FundChartStarted>(_onStarted);
    on<FundChartPeriodChanged>(_onPeriodChanged);
    on<FundChartLivePricesReceived>(_onLivePrices);
    on<FundChartRetryRequested>(_onRetry);
    on<FundChartStreamFailed>(_onStreamFailed);
  }

  final FundChartRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _onStarted(
    FundChartStarted event,
    Emitter<FundChartState> emit,
  ) async {
    emit(
      FundChartState(
        status: FundChartStatus.loading,
        fundId: event.fundId,
        exchange: event.exchange,
        period: state.period,
      ),
    );
    await _load(emit);
  }

  Future<void> _onRetry(
    FundChartRetryRequested event,
    Emitter<FundChartState> emit,
  ) async {
    if (state.fundId == null) return;
    emit(state.copyWith(status: FundChartStatus.loading, clearError: true));
    await _load(emit);
  }

  void _onPeriodChanged(
    FundChartPeriodChanged event,
    Emitter<FundChartState> emit,
  ) {
    if (state.status != FundChartStatus.loaded) return;
    emit(state.copyWith(period: event.period));
  }

  void _onStreamFailed(
    FundChartStreamFailed event,
    Emitter<FundChartState> emit,
  ) {
    if (state.status == FundChartStatus.loaded) {
      emit(state.copyWith(liveUnavailable: true));
    }
  }

  void _onLivePrices(
    FundChartLivePricesReceived event,
    Emitter<FundChartState> emit,
  ) {
    if (state.status != FundChartStatus.loaded || state.fundId == null) {
      return;
    }
    final marketKey = MarketInstrumentKey(
      fundId: state.fundId!,
      exchange: state.exchange,
    ).value;
    for (final tick in event.batch.updates) {
      if (tick.instrumentId != marketKey) continue;
      emit(_applyTick(tick));
      return;
    }
  }

  Future<void> _load(Emitter<FundChartState> emit) async {
    final fundId = state.fundId;
    if (fundId == null) return;
    try {
      final snapshot = await _repository.getChartData(
        fundId: fundId,
        exchange: state.exchange,
      );
      final cached = _livePrices.latestFor(snapshot.marketKey);
      final ltpMinor = cached?.ltpMinor ?? snapshot.latestLtpMinor;
      final timestamp = cached?.timestamp ?? DateTime.now();
      var historical = List<PriceCandle>.from(snapshot.intradayCandles);
      late final PriceCandle active;
      if (historical.isEmpty) {
        active = PriceCandle(
          startedAt: CandleAggregator.bucketStart(timestamp),
          openMinor: ltpMinor,
          highMinor: ltpMinor,
          lowMinor: ltpMinor,
          closeMinor: ltpMinor,
        );
      } else {
        final last = historical.removeLast();
        final update = CandleAggregator.apply(
          historical: historical,
          active: last,
          ltpMinor: ltpMinor,
          timestamp: timestamp,
        );
        historical = List<PriceCandle>.from(update.historical);
        active = update.active;
      }
      emit(
        state.copyWith(
          status: FundChartStatus.loaded,
          historicalCandles: historical,
          activeCandle: active,
          oneMonthHistory: snapshot.oneMonthHistory,
          threeMonthHistory: snapshot.threeMonthHistory,
          latestLtpMinor: ltpMinor,
          lastTickDirection: cached?.direction ?? LivePriceDirection.flat,
          liveUnavailable: false,
          clearError: true,
          symbol: snapshot.symbol,
        ),
      );
      await _watch(snapshot.liveSeed);
    } on Object {
      emit(
        state.copyWith(
          status: FundChartStatus.error,
          errorMessage: 'Unable to load chart',
        ),
      );
    }
  }

  Future<void> _watch(LiveInstrumentSeed seed) async {
    await _subscription?.cancel();
    await _lease?.dispose();
    final acquired = _livePrices.acquire(instruments: [seed]);
    _lease = acquired;
    _subscription = acquired.stream.listen(
      (batch) => add(FundChartLivePricesReceived(batch)),
      onError: (_) => add(const FundChartStreamFailed()),
    );
  }

  FundChartState _applyTick(LivePriceTick tick) {
    var historical = state.historicalCandles;
    var active = state.activeCandle;
    if (active == null) {
      active = PriceCandle(
        startedAt: CandleAggregator.bucketStart(tick.timestamp),
        openMinor: tick.ltpMinor,
        highMinor: tick.ltpMinor,
        lowMinor: tick.ltpMinor,
        closeMinor: tick.ltpMinor,
      );
    } else {
      final update = CandleAggregator.apply(
        historical: historical,
        active: active,
        ltpMinor: tick.ltpMinor,
        timestamp: tick.timestamp,
      );
      historical = update.historical;
      active = update.active;
    }
    return state.copyWith(
      historicalCandles: historical,
      activeCandle: active,
      latestLtpMinor: tick.ltpMinor,
      lastTickDirection: tick.direction,
      liveUnavailable: false,
    );
  }
}
