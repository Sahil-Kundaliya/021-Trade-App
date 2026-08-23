import 'dart:async';

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
    on<OrderBookOrdersChanged>(_ordersChanged);
    on<OrderBookCancelRequested>(_cancelRequested);
    if (_repository case final ReactiveOrderBookRepository reactive) {
      _changesSubscription = reactive.orderChanges.listen(
        (orders) => add(OrderBookOrdersChanged(orders)),
      );
    }
  }

  Future<void> _cancelRequested(
    OrderBookCancelRequested event,
    Emitter<OrderBookState> emit,
  ) async {
    try {
      await _repository.cancelOrder(event.orderId);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unable to cancel this order.'));
    }
  }

  final OrderBookRepository _repository;
  StreamSubscription<List<TradeOrder>>? _changesSubscription;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    return super.close();
  }

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

  void _ordersChanged(
    OrderBookOrdersChanged event,
    Emitter<OrderBookState> emit,
  ) {
    final orders = List<TradeOrder>.of(event.orders)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final immutable = List<TradeOrder>.unmodifiable(orders);
    emit(
      state.copyWith(
        status: immutable.isEmpty
            ? OrderBookStatus.empty
            : OrderBookStatus.loaded,
        allOrders: immutable,
        visibleOrders: _filter(immutable, state.selectedTab),
        clearError: true,
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
