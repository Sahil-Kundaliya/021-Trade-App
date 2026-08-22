import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist/src/watchlist/presentation/widgets/watchlist_stock_list.dart';

void main() {
  testWidgets('empty watchlist shows the fund empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WatchlistStockList(stocks: [])),
      ),
    );

    expect(find.text('No fund added'), findsOneWidget);
    expect(find.text('No watchlist available'), findsNothing);
  });
}
