import '../../market/trade_exchange.dart';
import '../parsing/json_value_reader.dart';

class MarketIndexDto {
  const MarketIndexDto({
    required this.id,
    required this.symbol,
    required this.exchange,
    required this.ltp,
    required this.previousClose,
    required this.tickSize,
  });

  factory MarketIndexDto.fromJson(Map<String, dynamic> json) => MarketIndexDto(
    id: JsonValueReader.string(json, 'id'),
    symbol: JsonValueReader.string(json, 'symbol'),
    exchange: TradeExchange.parse(JsonValueReader.string(json, 'exchange')),
    ltp: JsonValueReader.number(json, 'ltp'),
    previousClose: JsonValueReader.number(json, 'previousClose'),
    tickSize: JsonValueReader.number(json, 'tickSize'),
  );

  final String id;
  final String symbol;
  final TradeExchange exchange;
  final double ltp;
  final double previousClose;
  final double tickSize;

  double get change => ltp - previousClose;
  double get changePercent =>
      previousClose == 0 ? 0 : change / previousClose * 100;
}
