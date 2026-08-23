import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/trade_order.dart';
import '../../domain/repositories/orderbook_repository.dart';
import '../mappers/order_mapper.dart';

@LazySingleton(as: OrderBookRepository)
final class OrderBookRepositoryImpl
    implements OrderBookRepository, ReactiveOrderBookRepository {
  OrderBookRepositoryImpl(this._store);

  final OrderStore _store;

  @override
  Future<List<TradeOrder>> getOrders() async {
    final dtos = await _store.getOrders();
    return List<TradeOrder>.unmodifiable(dtos.map(OrderMapper.toDomain));
  }

  @override
  Future<bool> cancelOrder(String orderId) => _store.cancel(orderId);

  @override
  Stream<List<TradeOrder>> get orderChanges => _store.changes.map(
    (change) =>
        List<TradeOrder>.unmodifiable(change.orders.map(OrderMapper.toDomain)),
  );
}
