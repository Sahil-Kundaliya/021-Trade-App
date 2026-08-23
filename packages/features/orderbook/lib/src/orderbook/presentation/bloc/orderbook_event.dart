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

enum OrderBookTab { open, closed }
