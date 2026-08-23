import 'package:core_data/core_data.dart';

import '../entities/fund_details.dart';
import '../entities/price_candle.dart';

class FundChartSnapshot {
  const FundChartSnapshot({
    required this.fundId,
    required this.exchange,
    required this.symbol,
    required this.instrumentType,
    required this.intradayCandles,
    required this.oneMonthHistory,
    required this.threeMonthHistory,
    required this.latestLtpMinor,
    required this.previousCloseMinor,
    required this.tickSizeMinor,
  });

  final String fundId;
  final TradeExchange exchange;
  final String symbol;
  final String instrumentType;
  final List<PriceCandle> intradayCandles;
  final List<FundHistoryPoint> oneMonthHistory;
  final List<FundHistoryPoint> threeMonthHistory;
  final int latestLtpMinor;
  final int previousCloseMinor;
  final int tickSizeMinor;

  String get marketKey =>
      MarketInstrumentKey(fundId: fundId, exchange: exchange).value;

  LiveInstrumentSeed get liveSeed => LiveInstrumentSeed.fromPrices(
    marketKey: marketKey,
    fundId: fundId,
    exchange: exchange,
    assetType: switch (instrumentType) {
      'FUTURE' => LiveMarketAssetType.future,
      'OPTION' => LiveMarketAssetType.option,
      _ => LiveMarketAssetType.equity,
    },
    symbol: symbol,
    ltp: latestLtpMinor / 100,
    previousClose: previousCloseMinor / 100,
    tickSize: tickSizeMinor / 100,
  );
}

abstract interface class FundChartRepository {
  Future<FundChartSnapshot> getChartData({
    required String fundId,
    required TradeExchange exchange,
  });
}
