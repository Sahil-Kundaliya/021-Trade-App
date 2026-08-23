import '../../domain/entities/trade_order.dart';

sealed class OrderBookEvent {
  const OrderBookEvent();
}

final class OrderBookStarted extends OrderBookEvent {
  const OrderBookStarted();
}

final class OrderBookRetryRequested extends OrderBookEvent {
  const OrderBookRetryRequested();
}

final class OrderBookTabChanged extends OrderBookEvent {
  const OrderBookTabChanged(this.tab);

  final OrderBookTab tab;
}

final class OrderBookOrdersChanged extends OrderBookEvent {
  const OrderBookOrdersChanged(this.orders);

  final List<TradeOrder> orders;
}

final class OrderBookCancelRequested extends OrderBookEvent {
  const OrderBookCancelRequested(this.orderId);
  final String orderId;
}

enum OrderBookTab { open, closed }
