import '../models/order_dto.dart';
import '../../notifications/trading_order_event.dart';

class OrderBookChange {
  const OrderBookChange(this.orders, [this.events = const []]);

  final List<OrderDto> orders;
  final List<TradingOrderEvent> events;
}
