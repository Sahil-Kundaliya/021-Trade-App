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
    _subscription = null;
    await _lease?.dispose();
    _lease = null;
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
    if (state.period == event.period) return;
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
      final next = _applyTick(tick);
      if (_isNoOpTick(state, next)) return;
      emit(next);
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
      if (isClosed) return;
      final cached = _livePrices.latestFor(snapshot.marketKey);
      final ltpMinor = cached?.ltpMinor ?? snapshot.latestLtpMinor;
      final timestamp = cached?.timestamp ?? DateTime.now();
      final minute = CandleAggregator.seed(
        candles: snapshot.intradayCandles,
        ltpMinor: ltpMinor,
        timestamp: timestamp,
      );
      final daily = CandleAggregator.seed(
        candles: snapshot.dailyCandles,
        ltpMinor: ltpMinor,
        timestamp: timestamp,
        bucket: CandleBucket.day,
      );
      emit(
        state.copyWith(
          status: FundChartStatus.loaded,
          minuteHistorical: minute.historical,
          minuteActive: minute.active,
          dailyHistorical: daily.historical,
          dailyActive: daily.active,
          latestLtpMinor: ltpMinor,
          lastTickDirection: cached?.direction ?? LivePriceDirection.flat,
          liveUnavailable: false,
          clearError: true,
          symbol: snapshot.symbol,
        ),
      );
      unawaited(_watch(snapshot.liveSeed));
    } on Object {
      if (isClosed) return;
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
    if (isClosed) return;
    final acquired = _livePrices.acquire(instruments: [seed]);
    _lease = acquired;
    _subscription = acquired.stream.listen(
      (batch) => add(FundChartLivePricesReceived(batch)),
      onError: (_) => add(const FundChartStreamFailed()),
    );
  }

  FundChartState _applyTick(LivePriceTick tick) {
    final minute = _advance(
      historical: state.minuteHistorical,
      active: state.minuteActive,
      tick: tick,
    );
    final daily = _advance(
      historical: state.dailyHistorical,
      active: state.dailyActive,
      tick: tick,
      bucket: CandleBucket.day,
    );
    return state.copyWith(
      minuteHistorical: minute.historical,
      minuteActive: minute.active,
      dailyHistorical: daily.historical,
      dailyActive: daily.active,
      latestLtpMinor: tick.ltpMinor,
      lastTickDirection: tick.direction,
      liveUnavailable: false,
    );
  }

  CandleSeriesUpdate _advance({
    required List<PriceCandle> historical,
    required PriceCandle? active,
    required LivePriceTick tick,
    CandleBucket bucket = CandleBucket.minute,
  }) {
    if (active == null) {
      return CandleAggregator.seed(
        candles: const [],
        ltpMinor: tick.ltpMinor,
        timestamp: tick.timestamp,
        bucket: bucket,
      );
    }
    return CandleAggregator.apply(
      historical: historical,
      active: active,
      ltpMinor: tick.ltpMinor,
      timestamp: tick.timestamp,
      bucket: bucket,
    );
  }

  static bool _isNoOpTick(FundChartState current, FundChartState next) =>
      current.latestLtpMinor == next.latestLtpMinor &&
      current.lastTickDirection == next.lastTickDirection &&
      current.minuteActive == next.minuteActive &&
      current.dailyActive == next.dailyActive &&
      identical(current.minuteHistorical, next.minuteHistorical) &&
      identical(current.dailyHistorical, next.dailyHistorical);
}
