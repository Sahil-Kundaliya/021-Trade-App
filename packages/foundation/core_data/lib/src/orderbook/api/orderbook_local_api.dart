import '../models/order_dto.dart';

abstract interface class OrderBookLocalApi {
  Future<List<OrderDto>> getOrders();

  Future<void> saveOrders(List<OrderDto> orders);
}
