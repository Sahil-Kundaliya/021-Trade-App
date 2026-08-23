import 'package:core_data/core_data.dart' hide TradeExchange;

import '../enums/order_enums.dart';

class OrderInstrument {
  const OrderInstrument({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.instrumentType,
    required this.availableExchanges,
    required this.defaultExchange,
    this.exchange = TradeExchange.nse,
    this.marketByExchange = const {},
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
  final TradeExchange exchange;
  final Map<TradeExchange, OrderMarketListing> marketByExchange;
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
  String get marketKey =>
      MarketInstrumentKey(fundId: id, exchange: exchange).value;

  OrderInstrument forExchange(TradeExchange value) {
    final listing = marketByExchange[value];
    if (listing == null) return this;
    return OrderInstrument(
      id: id,
      symbol: symbol,
      companyName: companyName,
      instrumentType: instrumentType,
      availableExchanges: availableExchanges,
      defaultExchange: defaultExchange,
      exchange: value,
      marketByExchange: marketByExchange,
      ltp: listing.ltp,
      change: listing.change,
      changePercent: listing.changePercent,
      lotSize: lotSize,
      tickSize: listing.tickSize,
      previousClose: listing.previousClose,
      allowedOrderTypes: allowedOrderTypes,
      allowedProducts: allowedProducts,
    );
  }

  OrderInstrument withLivePrice(LivePriceTick tick) => OrderInstrument(
    id: id,
    symbol: symbol,
    companyName: companyName,
    instrumentType: instrumentType,
    availableExchanges: availableExchanges,
    defaultExchange: defaultExchange,
    exchange: exchange,
    marketByExchange: marketByExchange,
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

class OrderMarketListing {
  const OrderMarketListing({
    required this.ltp,
    required this.previousClose,
    required this.tickSize,
  });

  final double ltp;
  final double previousClose;
  final double tickSize;
  double get change => ltp - previousClose;
  double get changePercent =>
      previousClose == 0 ? 0 : change / previousClose * 100;
}
