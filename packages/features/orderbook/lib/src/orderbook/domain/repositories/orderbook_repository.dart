import '../entities/trade_order.dart';

abstract interface class OrderBookRepository {
  Future<List<TradeOrder>> getOrders();
}
