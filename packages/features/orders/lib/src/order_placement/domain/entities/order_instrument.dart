import '../enums/order_enums.dart';

class OrderInstrument {
  const OrderInstrument({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.instrumentType,
    required this.availableExchanges,
    required this.defaultExchange,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required this.lotSize,
    required this.tickSize,
    required this.allowedOrderTypes,
    required this.allowedProducts,
  });

  final String id;
  final String symbol;
  final String companyName;
  final OrderInstrumentType instrumentType;
  final List<TradeExchange> availableExchanges;
  final TradeExchange defaultExchange;
  final double ltp;
  final double change;
  final double changePercent;
  final int lotSize;
  final double tickSize;
  final List<TradeOrderType> allowedOrderTypes;
  final List<TradeProduct> allowedProducts;

  bool get isDerivative => instrumentType != OrderInstrumentType.equity;
  int get quantityStep => isDerivative ? lotSize : 1;
}
