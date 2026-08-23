import 'package:core_data/core_data.dart';

import '../../../domain/entities/price_candle.dart';

enum FundChartStatus { initial, loading, loaded, error }

enum FundChartPeriod {
  oneDay,
  oneMonth,
  threeMonths;

  bool get isIntraday => this == FundChartPeriod.oneDay;

  int get dailyHistoricalLookback => switch (this) {
    FundChartPeriod.oneDay => 0,
    FundChartPeriod.oneMonth => 21,
    FundChartPeriod.threeMonths => 90,
  };
}

sealed class FundChartEvent {
  const FundChartEvent();
}

final class FundChartStarted extends FundChartEvent {
  const FundChartStarted({required this.fundId, required this.exchange});
  final String fundId;
  final TradeExchange exchange;
}

final class FundChartPeriodChanged extends FundChartEvent {
  const FundChartPeriodChanged(this.period);
  final FundChartPeriod period;
}

final class FundChartLivePricesReceived extends FundChartEvent {
  const FundChartLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}

final class FundChartRetryRequested extends FundChartEvent {
  const FundChartRetryRequested();
}

final class FundChartStreamFailed extends FundChartEvent {
  const FundChartStreamFailed();
}

class FundChartState {
  const FundChartState({
    this.status = FundChartStatus.initial,
    this.fundId,
    this.exchange = TradeExchange.nse,
    this.period = FundChartPeriod.oneDay,
    this.minuteHistorical = const [],
    this.minuteActive,
    this.dailyHistorical = const [],
    this.dailyActive,
    this.latestLtpMinor,
    this.lastTickDirection = LivePriceDirection.flat,
    this.liveUnavailable = false,
    this.errorMessage,
    this.symbol = '',
  });

  final FundChartStatus status;
  final String? fundId;
  final TradeExchange exchange;
  final FundChartPeriod period;
  final List<PriceCandle> minuteHistorical;
  final PriceCandle? minuteActive;
  final List<PriceCandle> dailyHistorical;
  final PriceCandle? dailyActive;
  final int? latestLtpMinor;
  final LivePriceDirection lastTickDirection;
  final bool liveUnavailable;
  final String? errorMessage;
  final String symbol;

  List<PriceCandle> get visibleHistorical {
    if (period == FundChartPeriod.oneDay) return minuteHistorical;
    final all = dailyHistorical;
    final lookback = period.dailyHistoricalLookback;
    if (all.length <= lookback) return all;
    return all.sublist(all.length - lookback);
  }

  PriceCandle? get visibleActive =>
      period.isIntraday ? minuteActive : dailyActive;

  int get _historicalStart {
    if (period.isIntraday) return 0;
    final lookback = period.dailyHistoricalLookback;
    final length = dailyHistorical.length;
    return length > lookback ? length - lookback : 0;
  }

  List<PriceCandle> get _periodHistorical =>
      period.isIntraday ? minuteHistorical : dailyHistorical;

  int get visibleCount {
    final extra = visibleActive == null ? 0 : 1;
    return (_periodHistorical.length - _historicalStart) + extra;
  }

  PriceCandle candleAt(int index) {
    final historical = _periodHistorical;
    final start = _historicalStart;
    final historicalCount = historical.length - start;
    if (index < historicalCount) return historical[start + index];
    return visibleActive!;
  }

  double? get latestLtp =>
      latestLtpMinor == null ? null : latestLtpMinor! / 100;

  FundChartState copyWith({
    FundChartStatus? status,
    String? fundId,
    TradeExchange? exchange,
    FundChartPeriod? period,
    List<PriceCandle>? minuteHistorical,
    PriceCandle? minuteActive,
    bool clearMinuteActive = false,
    List<PriceCandle>? dailyHistorical,
    PriceCandle? dailyActive,
    bool clearDailyActive = false,
    int? latestLtpMinor,
    LivePriceDirection? lastTickDirection,
    bool? liveUnavailable,
    String? errorMessage,
    bool clearError = false,
    String? symbol,
  }) => FundChartState(
    status: status ?? this.status,
    fundId: fundId ?? this.fundId,
    exchange: exchange ?? this.exchange,
    period: period ?? this.period,
    minuteHistorical: minuteHistorical ?? this.minuteHistorical,
    minuteActive: clearMinuteActive
        ? null
        : minuteActive ?? this.minuteActive,
    dailyHistorical: dailyHistorical ?? this.dailyHistorical,
    dailyActive: clearDailyActive ? null : dailyActive ?? this.dailyActive,
    latestLtpMinor: latestLtpMinor ?? this.latestLtpMinor,
    lastTickDirection: lastTickDirection ?? this.lastTickDirection,
    liveUnavailable: liveUnavailable ?? this.liveUnavailable,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    symbol: symbol ?? this.symbol,
  );
}
