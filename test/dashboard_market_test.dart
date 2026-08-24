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
    final screener = find.byKey(const Key('market-screener'));
    expect(
      find.descendant(of: screener, matching: find.text('RELIANCE')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: screener, matching: find.text('ICICIBANK')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: screener, matching: find.text('ITC')),
      findsNothing,
    );
    expect(find.text('MARKET HEAT MAP'), findsOneWidget);
    expect(find.text('Equity · NSE'), findsOneWidget);
    for (final symbol in [
      'RELIANCE',
      'TCS',
      'INFY',
      'HDFCBANK',
      'ICICIBANK',
      'SBIN',
      'ITC',
      'LT',
      'BHARTIARTL',
      'AXISBANK',
    ]) {
      expect(find.text(symbol), findsWidgets);
    }
  });

  Future<void> tapScreenerLabel(WidgetTester tester, String label) async {
    final finder = find.descendant(
      of: find.byKey(const Key('market-screener')),
      matching: find.text(label),
    );
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

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
    await tapScreenerLabel(tester, 'Most Active');
    expect(
      find.descendant(
        of: find.byKey(const Key('market-screener')),
        matching: find.text('HDFCBANK'),
      ),
      findsOneWidget,
    );

    await tapVisible(tester, find.text('Futures'));
    await tapScreenerLabel(tester, 'Top Losers');
    expect(
      find.descendant(
        of: find.byKey(const Key('market-screener')),
        matching: find.text('INFY'),
      ),
      findsOneWidget,
    );

    await tapScreenerLabel(tester, 'Futures');
    expect(find.text('SBIN AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Top Losers'));
    await tapScreenerLabel(tester, 'Top Losers');
    expect(find.text('RELIANCE AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Most Active'));
    await tapScreenerLabel(tester, 'Most Active');
    expect(find.text('ITC AUG FUT'), findsOneWidget);

    await tapVisible(tester, find.text('Options'));
    await tapScreenerLabel(tester, 'Options');
    expect(find.text('HDFCBANK 730.00 CE'), findsOneWidget);
    expect(find.text('Call Movers'), findsOneWidget);
    expect(find.text('Put Movers'), findsOneWidget);

    await tapVisible(tester, find.text('Call Movers'));
    expect(find.text('HDFCBANK 730.00 CE'), findsOneWidget);

    await tapVisible(tester, find.text('Put Movers'));
    expect(find.text('ITC 270.00 PE'), findsOneWidget);
    await tapScreenerLabel(tester, 'Call Movers');
    expect(find.text('HDFCBANK 730.00 CE'), findsOneWidget);

    await tapScreenerLabel(tester, 'Put Movers');
    expect(find.text('ITC 270.00 PE'), findsOneWidget);
  });

  testWidgets('switching exchange updates the heat map subtitle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDashboard(tester);
    await finishLoading(tester);

    expect(find.text('Equity · NSE'), findsOneWidget);
    final exchange = find.byKey(const Key('market-screener-exchange'));
    await tester.ensureVisible(exchange);
    await tester.tap(exchange);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BSE').last);
    await tester.pumpAndSettle();
    expect(find.text('Equity · BSE'), findsOneWidget);
  });

  testWidgets('renders with the dark core_ui theme', (tester) async {
    await pumpDashboard(tester, themeMode: ThemeMode.dark);
    await finishLoading(tester);

    expect(find.text('Market Screener'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
