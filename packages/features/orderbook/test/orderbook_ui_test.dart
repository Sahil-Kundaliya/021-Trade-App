import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orderbook/src/orderbook/domain/entities/trade_order.dart';
import 'package:orderbook/src/orderbook/domain/repositories/orderbook_repository.dart';
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:orderbook/src/root/presentation/widgets/orderbook_content.dart';

void main() {
  testWidgets('single open and closed orders stay anchored below the tabs', (
    tester,
  ) async {
    final bloc = OrderBookBloc(
      _Repository([
        _order('open', OrderStatus.open),
        _order('closed', OrderStatus.executed),
      ]),
    )..add(const OrderBookStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(value: bloc, child: const OrderBookContent()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('TODAY')).dy, lessThan(220));

    await tester.tap(find.text('Closed (1)'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('TODAY')).dy, lessThan(220));
  });
}

final class _Repository implements OrderBookRepository {
  const _Repository(this.orders);
  final List<TradeOrder> orders;

  @override
  Future<List<TradeOrder>> getOrders() async => orders;

  @override
  Future<bool> cancelOrder(String orderId) async => true;
}

TradeOrder _order(String id, OrderStatus status) => TradeOrder(
  orderId: id,
  fundId: 'RELIANCE_EQ',
  symbol: 'RELIANCE',
  companyName: 'Reliance Industries',
  exchange: TradeExchange.nse,
  instrumentType: 'equity',
  side: OrderSide.buy,
  orderType: TradeOrderType.market,
  productType: TradeProductType.delivery,
  status: status,
  quantity: 1,
  filledQuantity: status == OrderStatus.executed ? 1 : 0,
  pendingQuantity: status == OrderStatus.executed ? 0 : 1,
  ltp: 1316,
  averagePrice: status == OrderStatus.executed ? 1316 : null,
  orderValue: 1316,
  validity: 'DAY',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
