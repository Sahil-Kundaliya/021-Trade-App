import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

void main() {
  Future<void> pumpOrders(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const OrdersPage(),
      ),
    );
  }

  testWidgets('shows static order book data and opens order details', (
    tester,
  ) async {
    await pumpOrders(tester);

    expect(find.text('Orders'), findsOneWidget);
    expect(find.byIcon(Icons.tune_outlined), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Executed'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('NSE'), findsWidgets);
    expect(find.text('Equity'), findsWidgets);
    expect(find.text('\u20B91,452.30'), findsOneWidget);

    await tester.tap(find.text('RELIANCE'));
    await tester.pumpAndSettle();

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('ORD20260822001'), findsOneWidget);
    expect(find.text('120000389201'), findsOneWidget);
    expect(find.text('DAY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter sheet exposes all static filter categories', (
    tester,
  ) async {
    await pumpOrders(tester);

    await tester.tap(find.byKey(const Key('orders-filter-button')));
    await tester.pumpAndSettle();

    expect(find.text('Filter Orders'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Side'), findsOneWidget);
    expect(find.text('Exchange'), findsOneWidget);
    expect(find.text('Order Type'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('BSE'), findsWidgets);
    expect(find.text('SL-M'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders safely on narrow dark and wide layouts', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpOrders(tester, themeMode: ThemeMode.dark);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1100, 800);
    await tester.pumpAndSettle();
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
