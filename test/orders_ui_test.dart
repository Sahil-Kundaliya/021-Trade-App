import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:orders/orders.dart';

void main() {
  late _FakeOrderPlacementRepository repository;
  late _FakeNavigator navigator;

  setUp(() async {
    await GetIt.instance.reset();
    repository = _FakeOrderPlacementRepository();
    navigator = _FakeNavigator();
    GetIt.instance.registerFactory<OrderPlacementBloc>(
      () => OrderPlacementBloc(repository),
    );
  });

  tearDown(() => GetIt.instance.reset());

  Future<void> pumpOrders(
    WidgetTester tester, {
    TradeSide? side,
    Size size = const Size(420, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: OrdersScreen(
          fundId: 'RELIANCE_EQ',
          exchange: TradeExchange.nse,
          side: side,
          navigator: navigator,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads the selected instrument and initial side', (tester) async {
    await pumpOrders(tester, side: TradeSide.sell);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('Reliance Industries'), findsOneWidget);
    expect(find.text('SELL'), findsWidgets);
    expect(find.text('Estimated Value'), findsWidgets);
    expect(find.text('₹1,316.00'), findsWidgets);
    expect(find.text('Order Book'), findsNothing);
  });

  testWidgets('configures, reviews, confirms and shows confirmation', (
    tester,
  ) async {
    await pumpOrders(tester);
    await tester.ensureVisible(find.text('Limit'));
    await tester.tap(find.text('Limit'));
    await tester.pumpAndSettle();
    expect(find.text('Limit Price'), findsWidgets);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'BUY').last);
    await tester.tap(find.widgetWithText(FilledButton, 'BUY').last);
    await tester.pumpAndSettle();
    expect(find.text('REVIEW ORDER'), findsOneWidget);
    expect(repository.placed, isEmpty);

    await tester.tap(find.text('Confirm Buy'));
    await tester.pumpAndSettle();
    expect(repository.placed, hasLength(1));
    expect(find.text('Order Placed'), findsOneWidget);
    expect(find.textContaining('OPEN'), findsOneWidget);
  });

  testWidgets('derivative quantity increments by a lot', (tester) async {
    repository.instrument = _instrument(
      type: OrderInstrumentType.option,
      lotSize: 750,
    );
    await pumpOrders(tester);
    expect(find.text('1 Lot · 750 Qty'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('2 Lots · 1500 Qty'), findsOneWidget);
  });
}

OrderInstrument _instrument({
  OrderInstrumentType type = OrderInstrumentType.equity,
  int lotSize = 1,
}) => OrderInstrument(
  id: 'RELIANCE_EQ',
  symbol: 'RELIANCE',
  companyName: 'Reliance Industries',
  instrumentType: type,
  availableExchanges: type == OrderInstrumentType.equity
      ? TradeExchange.values
      : const [TradeExchange.nse],
  defaultExchange: TradeExchange.nse,
  ltp: 1316,
  change: 2.8,
  changePercent: .21,
  lotSize: lotSize,
  tickSize: .05,
  allowedOrderTypes: TradeOrderType.values,
  allowedProducts: type == OrderInstrumentType.equity
      ? const [TradeProduct.delivery, TradeProduct.intraday]
      : const [TradeProduct.intraday, TradeProduct.overnight],
);

final class _FakeOrderPlacementRepository implements OrderPlacementRepository {
  OrderInstrument instrument = _instrument();
  final placed = <OrderDraft>[];

  @override
  Stream<void> get positionChanges => const Stream.empty();

  @override
  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  }) async => 100000;

  @override
  Future<OrderInstrument> getInstrument(String fundId) async => instrument;

  @override
  Future<PlacedOrder> placeOrder(OrderDraft draft) async {
    placed.add(draft);
    return PlacedOrder(
      id: 'order_test',
      draft: draft,
      status: draft.orderType == TradeOrderType.market
          ? PlacedOrderStatus.executed
          : PlacedOrderStatus.open,
      filledQuantity: draft.orderType == TradeOrderType.market
          ? draft.quantity
          : 0,
      pendingQuantity: draft.orderType == TradeOrderType.market
          ? 0
          : draft.quantity,
      averagePrice: draft.orderType == TradeOrderType.market
          ? draft.instrument.ltp
          : null,
      orderValue: draft.estimatedOrderValue,
      createdAt: DateTime(2026),
    );
  }
}

final class _FakeNavigator implements AppNavigator {
  @override
  Future<void> openSearch() async {}

  @override
  void goToDashboard() {}
  @override
  void goToPortfolio() {}
  @override
  void goToProfile() {}
  @override
  void goToWatchlist() {}
  @override
  Future<void> openFund({
    required String fundId,
    required TradeExchange exchange,
  }) async {}
  @override
  Future<void> openOrderBook() async {}
  @override
  Future<void> openAccountFunds() async {}
  @override
  Future<void> openLicenceInformation() async {}
  @override
  Future<void> openOrders({
    required String fundId,
    required TradeExchange exchange,
    TradeSide? side,
  }) async {}
  @override
  Future<void> pop() async {}
}
