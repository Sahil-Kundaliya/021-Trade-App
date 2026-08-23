import 'package:core_data/core_data.dart' as core;

enum OrderSide { buy, sell }

typedef TradeExchange = core.TradeExchange;

enum TradeOrderType { market, limit, stopLoss, stopLossMarket }

enum TradeProduct { delivery, intraday, overnight }

enum OrderValidity { day, ioc }

enum OrderInstrumentType { equity, future, option }

enum PlacedOrderStatus { open, triggerPending, executed }

extension TradeOrderTypeRules on TradeOrderType {
  bool get requiresLimitPrice =>
      this == TradeOrderType.limit || this == TradeOrderType.stopLoss;
  bool get requiresTriggerPrice =>
      this == TradeOrderType.stopLoss || this == TradeOrderType.stopLossMarket;
  bool get usesEstimatedMarketPrice =>
      this == TradeOrderType.market || this == TradeOrderType.stopLossMarket;
}
