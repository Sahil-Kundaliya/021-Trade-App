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

  testWidgets('keeps orders focused on order entry', (tester) async {
    await pumpOrders(tester);

    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Order entry'), findsOneWidget);
    expect(find.textContaining('Buy and sell order placement'), findsOneWidget);
    expect(find.text('Order Book'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders safely on narrow dark and wide layouts', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpOrders(tester, themeMode: ThemeMode.dark);
    expect(find.text('Order entry'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1100, 800);
    await tester.pumpAndSettle();
    expect(find.text('Order entry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
