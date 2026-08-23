import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/trade_order.dart';
import '../../domain/repositories/orderbook_repository.dart';
import '../mappers/order_mapper.dart';

@LazySingleton(as: OrderBookRepository)
final class OrderBookRepositoryImpl implements OrderBookRepository {
  OrderBookRepositoryImpl(this._localApi);

  final OrderBookLocalApi _localApi;

  @override
  Future<List<TradeOrder>> getOrders() async {
    final dtos = await _localApi.getOrders();
    return List<TradeOrder>.unmodifiable(dtos.map(OrderMapper.toDomain));
  }
}
