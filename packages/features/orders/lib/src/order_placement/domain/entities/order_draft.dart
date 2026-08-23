import 'order_instrument.dart';
import '../enums/order_enums.dart';

class OrderDraft {
  const OrderDraft({
    required this.instrument,
    required this.side,
    required this.exchange,
    required this.quantity,
    required this.orderType,
    required this.product,
    required this.validity,
    this.limitPrice,
    this.triggerPrice,
  });

  final OrderInstrument instrument;
  final OrderSide side;
  final TradeExchange exchange;
  final int quantity;
  final TradeOrderType orderType;
  final TradeProduct product;
  final OrderValidity validity;
  final double? limitPrice;
  final double? triggerPrice;

  double get estimatedOrderValue =>
      quantity *
      (orderType.requiresLimitPrice ? (limitPrice ?? 0) : instrument.ltp);
}
