import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:orderbook/src/orderbook/domain/entities/trade_order.dart';
import 'package:orderbook/src/orderbook/domain/repositories/orderbook_repository.dart';
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_state.dart';

void main() {
  test(
    'loads once, defaults to open, sorts, and filters tabs locally',
    () async {
      final repository = _Repository([
        _order('open', OrderStatus.open, DateTime(2026, 1, 1)),
        _order('pending', OrderStatus.pending, DateTime(2026, 1, 2)),
        _order('trigger', OrderStatus.triggerPending, DateTime(2026, 1, 3)),
        _order('partial', OrderStatus.partiallyFilled, DateTime(2026, 1, 4)),
        _order('executed', OrderStatus.executed, DateTime(2026, 1, 5)),
        _order('cancelled', OrderStatus.cancelled, DateTime(2026, 1, 6)),
        _order('rejected', OrderStatus.rejected, DateTime(2026, 1, 7)),
      ]);
      final bloc = OrderBookBloc(repository)..add(const OrderBookStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == OrderBookStatus.loaded,
      );

      expect(bloc.state.selectedTab, OrderBookTab.open);
      expect(bloc.state.visibleOrders.map((order) => order.orderId), [
        'partial',
        'trigger',
        'pending',
        'open',
      ]);
      expect(repository.calls, 1);

      bloc.add(const OrderBookTabChanged(OrderBookTab.closed));
      await bloc.stream.firstWhere(
        (state) => state.selectedTab == OrderBookTab.closed,
      );
      expect(bloc.state.visibleOrders.map((order) => order.orderId), [
        'rejected',
        'cancelled',
        'executed',
      ]);
      expect(repository.calls, 1);
      await bloc.close();
    },
  );

  test('empty repository produces tab-specific empty-capable state', () async {
    final bloc = OrderBookBloc(_Repository([]))..add(const OrderBookStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderBookStatus.empty,
    );
    expect(bloc.state.selectedTab, OrderBookTab.open);
    expect(bloc.state.visibleOrders, isEmpty);
    await bloc.close();
  });

  test(
    'moves an executed order from open to closed without a reload',
    () async {
      final repository = _ReactiveRepository([
        _order('limit', OrderStatus.open, DateTime(2026, 1, 1)),
      ]);
      final bloc = OrderBookBloc(repository)..add(const OrderBookStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == OrderBookStatus.loaded,
      );

      repository.emit([
        _order('limit', OrderStatus.executed, DateTime(2026, 1, 2)),
      ]);
      await bloc.stream.firstWhere((state) => state.closedCount == 1);

      expect(bloc.state.openCount, 0);
      expect(bloc.state.visibleOrders, isEmpty);
      expect(repository.calls, 1);
      bloc.add(const OrderBookTabChanged(OrderBookTab.closed));
      await bloc.stream.firstWhere(
        (state) => state.selectedTab == OrderBookTab.closed,
      );
      expect(bloc.state.visibleOrders.single.status, OrderStatus.executed);
      await bloc.close();
      await repository.close();
    },
  );
}

class _Repository implements OrderBookRepository {
  _Repository(this.orders);
  final List<TradeOrder> orders;
  int calls = 0;
  @override
  Future<List<TradeOrder>> getOrders() async {
    calls++;
    return orders;
  }

  @override
  Future<bool> cancelOrder(String orderId) async => true;
}

final class _ReactiveRepository extends _Repository
    implements ReactiveOrderBookRepository {
  _ReactiveRepository(super.orders);

  final _changes = StreamController<List<TradeOrder>>.broadcast(sync: true);

  @override
  Stream<List<TradeOrder>> get orderChanges => _changes.stream;

  void emit(List<TradeOrder> orders) => _changes.add(orders);
  Future<void> close() => _changes.close();
}

TradeOrder _order(String id, OrderStatus status, DateTime createdAt) =>
    TradeOrder(
      orderId: id,
      fundId: 'fund',
      symbol: 'TEST',
      companyName: 'Test',
      exchange: TradeExchange.nse,
      instrumentType: 'Equity',
      side: OrderSide.buy,
      orderType: TradeOrderType.market,
      productType: TradeProductType.delivery,
      status: status,
      quantity: 1,
      filledQuantity: status == OrderStatus.executed ? 1 : 0,
      pendingQuantity: status == OrderStatus.executed ? 0 : 1,
      ltp: 1,
      validity: 'DAY',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
