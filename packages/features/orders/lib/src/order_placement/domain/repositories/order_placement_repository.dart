import '../entities/order_draft.dart';
import '../entities/order_instrument.dart';
import '../entities/placed_order.dart';

abstract interface class OrderPlacementRepository {
  Future<OrderInstrument> getInstrument(String fundId);
  Future<PlacedOrder> placeOrder(OrderDraft draft);
}
