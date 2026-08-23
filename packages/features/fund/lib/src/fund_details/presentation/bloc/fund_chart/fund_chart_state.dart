import 'package:core_data/core_data.dart';

import '../../../domain/entities/fund_details.dart';
import '../../../domain/entities/price_candle.dart';

enum FundChartStatus { initial, loading, loaded, error }

enum FundChartPeriod { oneDay, oneMonth, threeMonths }

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
    this.historicalCandles = const [],
    this.activeCandle,
    this.oneMonthHistory = const [],
    this.threeMonthHistory = const [],
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
  final List<PriceCandle> historicalCandles;
  final PriceCandle? activeCandle;
  final List<FundHistoryPoint> oneMonthHistory;
  final List<FundHistoryPoint> threeMonthHistory;
  final int? latestLtpMinor;
  final LivePriceDirection lastTickDirection;
  final bool liveUnavailable;
  final String? errorMessage;
  final String symbol;

  List<PriceCandle> get candles {
    final active = activeCandle;
    if (active == null) return historicalCandles;
    return [...historicalCandles, active];
  }

  double? get latestLtp =>
      latestLtpMinor == null ? null : latestLtpMinor! / 100;

  List<FundHistoryPoint> get selectedHistory => period ==
          FundChartPeriod.oneMonth
      ? oneMonthHistory
      : threeMonthHistory;

  FundChartState copyWith({
    FundChartStatus? status,
    String? fundId,
    TradeExchange? exchange,
    FundChartPeriod? period,
    List<PriceCandle>? historicalCandles,
    PriceCandle? activeCandle,
    bool clearActiveCandle = false,
    List<FundHistoryPoint>? oneMonthHistory,
    List<FundHistoryPoint>? threeMonthHistory,
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
    historicalCandles: historicalCandles ?? this.historicalCandles,
    activeCandle: clearActiveCandle ? null : activeCandle ?? this.activeCandle,
    oneMonthHistory: oneMonthHistory ?? this.oneMonthHistory,
    threeMonthHistory: threeMonthHistory ?? this.threeMonthHistory,
    latestLtpMinor: latestLtpMinor ?? this.latestLtpMinor,
    lastTickDirection: lastTickDirection ?? this.lastTickDirection,
    liveUnavailable: liveUnavailable ?? this.liveUnavailable,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    symbol: symbol ?? this.symbol,
  );
}
