import '../../domain/entities/trade_order.dart';
import 'orderbook_event.dart';

enum OrderBookStatus { initial, loading, loaded, empty, error }

class OrderBookState {
  const OrderBookState({
    this.status = OrderBookStatus.initial,
    this.allOrders = const [],
    this.visibleOrders = const [],
    this.selectedTab = OrderBookTab.open,
    this.errorMessage,
  });

  final OrderBookStatus status;
  final List<TradeOrder> allOrders;
  final List<TradeOrder> visibleOrders;
  final OrderBookTab selectedTab;
  final String? errorMessage;

  int get openCount => allOrders.where((order) => order.status.isOpen).length;
  int get closedCount => allOrders.length - openCount;

  OrderBookState copyWith({
    OrderBookStatus? status,
    List<TradeOrder>? allOrders,
    List<TradeOrder>? visibleOrders,
    OrderBookTab? selectedTab,
    String? errorMessage,
    bool clearError = false,
  }) => OrderBookState(
    status: status ?? this.status,
    allOrders: allOrders ?? this.allOrders,
    visibleOrders: visibleOrders ?? this.visibleOrders,
    selectedTab: selectedTab ?? this.selectedTab,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
