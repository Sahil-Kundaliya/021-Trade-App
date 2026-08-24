import 'package:core_ui/core_ui.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'helpers/test_trading_api.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
    await installImmediateTradingApi();
  });

  Future<void> finishLoading(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const DashboardPage(),
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
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

  testWidgets('shows the new dashboard sections in the requested order', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await finishLoading(tester);

    final sectionTitles = [
      'Portfolio Summary',
      'Featured',
      'Market Screener',
      'Top Market News',
    ];
    final offsets = sectionTitles
        .map((title) => tester.getTopLeft(find.text(title)).dy)
        .toList(growable: false);

    expect(offsets, orderedEquals(offsets.toList()..sort()));
    expect(find.text('Current Value'), findsOneWidget);
    expect(find.text('Invested Value'), findsOneWidget);
    expect(
      find.text('Benchmark indices end higher as banks lead gains'),
      findsOneWidget,
    );
    expect(
      find.text('Metal stocks gain as commodity prices recover'),
      findsOneWidget,
    );
  });

  testWidgets('switches category data and resets to the first valid tab', (
    tester,
  ) async {
    await pumpDashboard(tester);
    await finishLoading(tester);

    await tapVisible(tester, find.text('Most Active'));
    expect(find.text('HDFCBANK'), findsOneWidget);

    await tapVisible(tester, find.text('Top Losers'));
    expect(find.text('INFY'), findsOneWidget);

    await tapVisible(tester, find.text('Futures'));
    expect(find.text('SBIN AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Top Losers'));
    expect(find.text('RELIANCE AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Most Active'));
    expect(find.text('ITC AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Options'));
    expect(find.text('HDFCBANK 730.00 CE'), findsOneWidget);
    expect(find.text('Call Movers'), findsOneWidget);
    expect(find.text('Put Movers'), findsOneWidget);

    await tapVisible(tester, find.text('Call Movers'));
    expect(find.text('HDFCBANK 730.00 CE'), findsOneWidget);

    await tapVisible(tester, find.text('Put Movers'));
    expect(find.text('ITC 270.00 PE'), findsOneWidget);
  });

  testWidgets('renders with the dark core_ui theme', (tester) async {
    await pumpDashboard(tester, themeMode: ThemeMode.dark);
    await finishLoading(tester);

    expect(find.text('Market Screener'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
