import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/fund_chart_repository.dart';
import '../../domain/repositories/fund_repository.dart';
import '../mappers/fund_chart_mapper.dart';

@LazySingleton(as: FundChartRepository)
final class FundChartRepositoryImpl implements FundChartRepository {
  const FundChartRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;

  @override
  Future<FundChartSnapshot> getChartData({
    required String fundId,
    required TradeExchange exchange,
  }) async {
    final funds = await _tradingLocalApi.getFunds();
    for (final fund in funds) {
      if (fund.id != fundId) continue;
      try {
        final resolved = fund.forExchange(exchange);
        return FundChartSnapshot(
          fundId: resolved.id,
          exchange: exchange,
          symbol: resolved.symbol,
          instrumentType: resolved.instrumentType,
          intradayCandles: FundChartMapper.candles(resolved.intradayCandles),
          oneMonthHistory: FundChartMapper.history(
            resolved.oneMonthPriceHistory,
          ),
          threeMonthHistory: FundChartMapper.history(
            resolved.threeMonthPriceHistory,
          ),
          latestLtpMinor: (resolved.ltp * 100).round(),
          previousCloseMinor: (resolved.previousClose * 100).round(),
          tickSizeMinor: (resolved.tickSize * 100).round().clamp(1, 1 << 30),
        );
      } on Object {
        throw FundNotFoundException(fundId);
      }
    }
    throw FundNotFoundException(fundId);
  }
}
