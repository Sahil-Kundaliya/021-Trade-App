import 'package:core_ui/core_ui.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    expect(find.text('Market Screener'), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('TCS'), findsOneWidget);
    expect(find.text('ITC'), findsNothing);
  });

  testWidgets('switches category data and resets to the first valid tab', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Most Active'));
    await tester.pumpAndSettle();
    expect(find.text('HDFCBANK'), findsOneWidget);

    await tester.tap(find.text('Top Losers'));
    await tester.pumpAndSettle();
    expect(find.text('SBIN'), findsOneWidget);

    await tester.tap(find.text('Futures'));
    await tester.pumpAndSettle();
    expect(find.text('RELIANCE AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Top Losers'));
    await tester.pumpAndSettle();
    expect(find.text('SBIN AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Most Active'));
    await tester.pumpAndSettle();
    expect(find.text('NIFTY AUG FUT'), findsOneWidget);

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();
    expect(find.text('NIFTY 25000 CE'), findsOneWidget);
    expect(find.text('Call Movers'), findsOneWidget);
    expect(find.text('Put Movers'), findsOneWidget);

    await tester.tap(find.text('Call Movers'));
    await tester.pumpAndSettle();
    expect(find.text('BANKNIFTY 51500 CE'), findsOneWidget);

    await tester.tap(find.text('Put Movers'));
    await tester.pumpAndSettle();
    expect(find.text('AXISBANK 1150 PE'), findsOneWidget);
  });

  testWidgets('renders with the dark core_ui theme', (tester) async {
    await pumpDashboard(tester, themeMode: ThemeMode.dark);

    expect(find.text('Market Screener'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
