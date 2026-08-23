import '../orderbook/models/order_dto.dart';

enum TradingOrderEventType { placed, triggered, executed, cancelled, rejected }

class TradingOrderEvent {
  const TradingOrderEvent({required this.type, required this.order});

  final TradingOrderEventType type;
  final OrderDto order;

  String get eventId =>
      '${order.id}:${type.name}:${order.updatedAt.microsecondsSinceEpoch}';
}
