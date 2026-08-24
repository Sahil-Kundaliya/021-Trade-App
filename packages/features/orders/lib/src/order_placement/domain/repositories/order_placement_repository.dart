import '../entities/order_draft.dart';
import '../entities/order_instrument.dart';
import '../entities/placed_order.dart';
import '../enums/order_enums.dart';

abstract interface class OrderPlacementRepository {
  Future<OrderInstrument> getInstrument(String fundId);
  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  });
  Future<double> getAvailableFunds();
  Future<double> addFunds(double amount);
  Stream<void> get positionChanges;
  Future<PlacedOrder> placeOrder(OrderDraft draft);
}
