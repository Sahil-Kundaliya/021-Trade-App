import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist/watchlist.dart';

import 'helpers/test_trading_api.dart';

void main() {
  setUpAll(installImmediateTradingApi);

  Future<void> pumpWatchlist(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const WatchlistPage(),
      ),
    );
  }

  testWidgets('shows the header, market indices, Default, and its funds', (
    tester,
  ) async {
    await pumpWatchlist(tester);
    await tester.pumpAndSettle();

    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text('NIFTY 50'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Watchlist 2'), findsNothing);
    expect(find.text('Watchlist 3'), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('TCS'), findsOneWidget);
    expect(find.text('\u20B91,316.00'), findsOneWidget);
    expect(find.text('+2.80  +0.21%'), findsOneWidget);
    expect(find.text('Recommended'), findsWidgets);
    expect(find.text('Top Loser'), findsWidgets);
    expect(find.text('Equity'), findsNothing);
    expect(find.byIcon(Icons.bookmark), findsNothing);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);
  });

  testWidgets('does not fabricate additional watchlists', (tester) async {
    await pumpWatchlist(tester);
    await tester.pumpAndSettle();

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Watchlist 2'), findsNothing);
    expect(find.text('Watchlist 3'), findsNothing);
    expect(find.text('RELIANCE'), findsOneWidget);
  });

  testWidgets('renders safely on a narrow screen and in dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWatchlist(tester, themeMode: ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(find.text('RELIANCE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
