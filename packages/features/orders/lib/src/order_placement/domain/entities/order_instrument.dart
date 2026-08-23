import 'package:core_data/core_data.dart';

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
    this.previousClose = 1,
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
  final double previousClose;
  final List<TradeOrderType> allowedOrderTypes;
  final List<TradeProduct> allowedProducts;

  bool get isDerivative => instrumentType != OrderInstrumentType.equity;
  int get quantityStep => isDerivative ? lotSize : 1;

  OrderInstrument withLivePrice(LivePriceTick tick) => OrderInstrument(
    id: id,
    symbol: symbol,
    companyName: companyName,
    instrumentType: instrumentType,
    availableExchanges: availableExchanges,
    defaultExchange: defaultExchange,
    ltp: tick.ltp,
    change: tick.change,
    changePercent: tick.changePercent,
    lotSize: lotSize,
    tickSize: tickSize,
    previousClose: previousClose,
    allowedOrderTypes: allowedOrderTypes,
    allowedProducts: allowedProducts,
  );
}
