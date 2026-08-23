import 'trade_exchange.dart';

final class MarketInstrumentKey {
  const MarketInstrumentKey({required this.fundId, required this.exchange});

  final String fundId;
  final TradeExchange exchange;

  String get value => '$fundId:${exchange.code}';

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      other is MarketInstrumentKey &&
      other.fundId == fundId &&
      other.exchange == exchange;

  @override
  int get hashCode => Object.hash(fundId, exchange);
}
