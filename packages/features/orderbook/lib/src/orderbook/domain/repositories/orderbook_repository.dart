import '../entities/trade_order.dart';

abstract interface class OrderBookRepository {
  Future<List<TradeOrder>> getOrders();
  Future<bool> cancelOrder(String orderId);
}

abstract interface class ReactiveOrderBookRepository {
  Stream<List<TradeOrder>> get orderChanges;
}
