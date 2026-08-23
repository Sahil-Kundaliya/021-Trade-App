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
    expect(find.text('+2.80 (+0.21%)'), findsOneWidget);
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

  testWidgets('creates, long-press renames, and settings deletes a watchlist', (
    tester,
  ) async {
    await pumpWatchlist(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('CREATE WATCHLIST'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('watchlist-name-field')),
      'Banking',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Banking'), findsOneWidget);
    expect(find.text('No fund added'), findsOneWidget);

    await tester.longPress(find.text('Banking'));
    await tester.pumpAndSettle();
    expect(find.text('WATCHLIST OPTIONS'), findsOneWidget);
    expect(find.text('Rename Watchlist'), findsOneWidget);
    expect(find.text('Delete Watchlist'), findsOneWidget);

    await tester.tap(find.text('Rename Watchlist'));
    await tester.pumpAndSettle();
    final nameField = tester.widget<TextField>(
      find.byKey(const Key('watchlist-name-field')),
    );
    expect(nameField.controller!.text, 'Banking');
    await tester.enterText(
      find.byKey(const Key('watchlist-name-field')),
      'Banks',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Banks'), findsOneWidget);
    expect(find.text('Banking'), findsNothing);

    await tester.longPress(find.text('Banks'));
    await tester.pumpAndSettle();
    expect(find.text('Banks'), findsWidgets);
    await tester.tap(find.text('Delete Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('DELETE WATCHLIST?'), findsOneWidget);
    expect(find.text('Delete "Banks"?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Banks'), findsOneWidget);

    await tester.longPress(find.text('Banks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Watchlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Banks'), findsNothing);
    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('settings lists Default pinned and reorderable user watchlists', (
    tester,
  ) async {
    await pumpWatchlist(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('watchlist-name-field')),
      'Banking',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('WATCHLIST SETTINGS'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
  });
}
