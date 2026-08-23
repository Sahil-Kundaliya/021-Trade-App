import 'order_draft.dart';
import '../enums/order_enums.dart';

class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.draft,
    required this.status,
    required this.filledQuantity,
    required this.pendingQuantity,
    required this.orderValue,
    required this.createdAt,
    this.averagePrice,
  });

  final String id;
  final OrderDraft draft;
  final PlacedOrderStatus status;
  final int filledQuantity;
  final int pendingQuantity;
  final double? averagePrice;
  final double orderValue;
  final DateTime createdAt;
}
