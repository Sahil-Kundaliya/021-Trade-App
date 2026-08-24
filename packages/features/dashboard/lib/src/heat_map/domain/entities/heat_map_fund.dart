import 'package:core_data/core_data.dart';

class HeatMapFund {
  const HeatMapFund({
    required this.fundId,
    required this.exchange,
    required this.symbol,
    required this.companyName,
    required this.heatMapWeight,
    required this.initialLtp,
    required this.previousClose,
    required this.tickSize,
  });

  final String fundId;
  final TradeExchange exchange;
  final String symbol;
  final String companyName;
  final double heatMapWeight;
  final double initialLtp;
  final double previousClose;
  final double tickSize;

  String get marketKey =>
      MarketInstrumentKey(fundId: fundId, exchange: exchange).value;
}
