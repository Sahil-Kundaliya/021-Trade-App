import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/trade_order.dart';
import '../../domain/repositories/orderbook_repository.dart';
import 'orderbook_event.dart';
import 'orderbook_state.dart';

@injectable
class OrderBookBloc extends Bloc<OrderBookEvent, OrderBookState> {
  OrderBookBloc(this._repository) : super(const OrderBookState()) {
    on<OrderBookStarted>(_load);
    on<OrderBookRetryRequested>(_load);
    on<OrderBookTabChanged>(_changeTab);
  }

  final OrderBookRepository _repository;

  Future<void> _load(OrderBookEvent event, Emitter<OrderBookState> emit) async {
    emit(state.copyWith(status: OrderBookStatus.loading, clearError: true));
    try {
      final orders = List<TradeOrder>.of(await _repository.getOrders())
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final immutable = List<TradeOrder>.unmodifiable(orders);
      final visible = _filter(immutable, state.selectedTab);
      emit(
        state.copyWith(
          status: immutable.isEmpty
              ? OrderBookStatus.empty
              : OrderBookStatus.loaded,
          allOrders: immutable,
          visibleOrders: visible,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: OrderBookStatus.error,
          errorMessage: 'Unable to load orders.',
        ),
      );
    }
  }

  void _changeTab(OrderBookTabChanged event, Emitter<OrderBookState> emit) {
    if (event.tab == state.selectedTab) return;
    emit(
      state.copyWith(
        selectedTab: event.tab,
        visibleOrders: _filter(state.allOrders, event.tab),
      ),
    );
  }

  static List<TradeOrder> _filter(List<TradeOrder> orders, OrderBookTab tab) =>
      List<TradeOrder>.unmodifiable(
        orders.where(
          (order) => tab == OrderBookTab.open
              ? order.status.isOpen
              : !order.status.isOpen,
        ),
      );
}
