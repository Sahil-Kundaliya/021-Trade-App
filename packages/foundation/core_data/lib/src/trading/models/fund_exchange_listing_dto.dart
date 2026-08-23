import '../../market/trade_exchange.dart';
import '../parsing/json_value_reader.dart';
import 'price_candle_dto.dart';

class FundExchangeListingDto {
  const FundExchangeListingDto({
    required this.fundId,
    required this.exchange,
    required this.ltp,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.tickSize,
    this.intradayCandles = const [],
    this.dailyCandles = const [],
  });

  factory FundExchangeListingDto.fromJson(Map<String, dynamic> json) =>
      FundExchangeListingDto(
        fundId: JsonValueReader.string(json, 'fundId'),
        exchange: TradeExchange.parse(JsonValueReader.string(json, 'exchange')),
        ltp: JsonValueReader.number(json, 'ltp'),
        previousClose: JsonValueReader.number(json, 'previousClose'),
        open: JsonValueReader.number(json, 'open'),
        high: JsonValueReader.number(json, 'high'),
        low: JsonValueReader.number(json, 'low'),
        volume: JsonValueReader.integer(json, 'volume'),
        tickSize: JsonValueReader.number(json, 'tickSize'),
        intradayCandles: PriceCandleDto.listFrom(json, 'intradayCandles'),
        dailyCandles: PriceCandleDto.listFrom(json, 'dailyCandles'),
      );

  final String fundId;
  final TradeExchange exchange;
  final double ltp;
  final double previousClose;
  final double open;
  final double high;
  final double low;
  final int volume;
  final double tickSize;
  final List<PriceCandleDto> intradayCandles;
  final List<PriceCandleDto> dailyCandles;

  double get change => ltp - previousClose;
  double get changePercent =>
      previousClose == 0 ? 0 : change / previousClose * 100;
}
