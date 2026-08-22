import 'package:core_ui/core_ui.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_trading_api.dart';

void main() {
  setUpAll(installImmediateTradingApi);

  Future<void> finishLoading(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const DashboardPage(),
      ),
    );
  }

  testWidgets('shows equity gainers by default and limits the list to five', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await finishLoading(tester);

    expect(find.text('Market Screener'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('ICICIBANK'), findsOneWidget);
    expect(find.text('ITC'), findsNothing);
  });

  testWidgets('switches category data and resets to the first valid tab', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await finishLoading(tester);

    await tester.tap(find.text('Most Active'));
    await finishLoading(tester);
    expect(find.text('HDFCBANK'), findsOneWidget);

    await tester.tap(find.text('Top Losers'));
    await tester.pumpAndSettle();
    expect(find.text('INFY'), findsOneWidget);

    await tester.tap(find.text('Futures'));
    await tester.pumpAndSettle();
    expect(find.text('HDFCBANK AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Top Losers'));
    await tester.pumpAndSettle();
    expect(find.text('RELIANCE AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Most Active'));
    await tester.pumpAndSettle();
    expect(find.text('ITC AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();
    expect(find.text('HDFCBANK 730 CE'), findsOneWidget);
    expect(find.text('Call Movers'), findsOneWidget);
    expect(find.text('Put Movers'), findsOneWidget);

    await tester.tap(find.text('Call Movers'));
    await tester.pumpAndSettle();
    expect(find.text('HDFCBANK 730 CE'), findsOneWidget);

    await tester.tap(find.text('Put Movers'));
    await tester.pumpAndSettle();
    expect(find.text('ITC 270 PE'), findsOneWidget);
  });

  testWidgets('renders with the dark core_ui theme', (tester) async {
    await pumpDashboard(tester, themeMode: ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(find.text('Market Screener'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
