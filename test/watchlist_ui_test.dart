import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist/watchlist.dart';

void main() {
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

  testWidgets('shows the header, market indices, tabs, and default stocks', (
    tester,
  ) async {
    await pumpWatchlist(tester);

    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.text('NIFTY 50'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Watchlist 2'), findsOneWidget);
    expect(find.text('Watchlist 3'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('TCS'), findsOneWidget);
    expect(find.text('\u20B91,452.30'), findsOneWidget);
    expect(find.text('+18.40  +1.28%'), findsOneWidget);
    expect(find.text('Recommended'), findsNWidgets(2));
    expect(find.text('Top Loser'), findsNWidgets(2));
    expect(find.text('Equity'), findsNothing);
    expect(find.byIcon(Icons.bookmark), findsNothing);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);
  });

  testWidgets('switches between the static watchlist data sets', (
    tester,
  ) async {
    await pumpWatchlist(tester);

    await tester.tap(find.text('Watchlist 2'));
    await tester.pump();
    expect(find.text('SBIN'), findsOneWidget);
    expect(find.text('TCS'), findsNothing);

    await tester.tap(find.text('Watchlist 3'));
    await tester.pump();
    expect(find.text('SBIN'), findsOneWidget);
    expect(find.text('ITC'), findsNothing);
  });

  testWidgets('renders safely on a narrow screen and in dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWatchlist(tester, themeMode: ThemeMode.dark);

    expect(find.text('RELIANCE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
