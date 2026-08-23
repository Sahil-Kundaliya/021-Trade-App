enum OrderSide { buy, sell }

enum OrderStatus {
  open,
  pending,
  triggerPending,
  partiallyFilled,
  executed,
  cancelled,
  rejected;

  bool get isOpen => switch (this) {
    open || pending || triggerPending || partiallyFilled => true,
    executed || cancelled || rejected => false,
  };
}

enum TradeOrderType { market, limit, stopLoss, stopLossMarket }

enum TradeProductType { delivery, intraday, overnight }

enum TradeExchange { nse, bse }

class TradeOrder {
  const TradeOrder({
    required this.orderId,
    required this.fundId,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.instrumentType,
    required this.side,
    required this.orderType,
    required this.productType,
    required this.status,
    required this.quantity,
    required this.filledQuantity,
    required this.pendingQuantity,
    required this.ltp,
    required this.validity,
    required this.createdAt,
    required this.updatedAt,
    this.exchangeOrderId,
    this.averagePrice,
    this.limitPrice,
    this.triggerPrice,
    this.orderValue,
    this.rejectionReason,
  });

  final String orderId;
  final String? exchangeOrderId;
  final String fundId;
  final String symbol;
  final String companyName;
  final TradeExchange exchange;
  final String instrumentType;
  final OrderSide side;
  final TradeOrderType orderType;
  final TradeProductType productType;
  final OrderStatus status;
  final int quantity;
  final int filledQuantity;
  final int pendingQuantity;
  final double ltp;
  final double? averagePrice;
  final double? limitPrice;
  final double? triggerPrice;
  final double? orderValue;
  final String validity;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
}
