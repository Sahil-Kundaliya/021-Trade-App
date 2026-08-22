import 'package:fund/fund.dart';
import 'package:orders/orders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_two_one_trade_assignment/app/app.dart';

import 'helpers/test_trading_api.dart';

void main() {
  setUpAll(installImmediateTradingApi);

  testWidgets('bottom navigation stays synchronized with tab routing', (
    tester,
  ) async {
    await tester.pumpWidget(TradingApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsExactly(2));

    await tester.tap(find.text('Watchlist').last);
    await tester.pumpAndSettle();
    expect(find.text('Watchlist'), findsExactly(2));

    await tester.tap(find.text('Portfolio').last);
    await tester.pumpAndSettle();
    expect(find.text('Portfolio'), findsExactly(2));

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsExactly(2));
  });

  testWidgets('navigator opens and pops standalone routes', (tester) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.goToWatchlist();
    await tester.pumpAndSettle();
    expect(find.text('Watchlist'), findsExactly(2));

    app.navigator.goToPortfolio();
    await tester.pumpAndSettle();
    expect(find.text('Portfolio'), findsExactly(2));

    app.navigator.goToProfile();
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsExactly(2));

    app.navigator.goToDashboard();
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsExactly(2));

    app.navigator.openOrders();
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);

    await app.navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsNothing);

    app.navigator.openFund();
    await tester.pumpAndSettle();
    expect(find.byType(FundSheet), findsOneWidget);
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('Sell'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FundSheet), findsNothing);
    expect(find.text('Dashboard'), findsExactly(2));
  });

  testWidgets('all main feature entry points open the shared fund sheet', (
    tester,
  ) async {
    await tester.pumpWidget(TradingApp());
    await tester.pumpAndSettle();

    Future<void> openAndCloseFunds(Finder entryPoint) async {
      await tester.ensureVisible(entryPoint);
      await tester.tap(entryPoint);
      await tester.pumpAndSettle();
      expect(find.byType(FundSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Close funds'));
      await tester.pumpAndSettle();
      expect(find.byType(FundSheet), findsNothing);
    }

    await openAndCloseFunds(find.text('RELIANCE'));

    await tester.tap(find.text('Watchlist').last);
    await tester.pumpAndSettle();
    await openAndCloseFunds(find.text('RELIANCE'));

    await tester.tap(find.text('Portfolio').last);
    await tester.pumpAndSettle();
    await openAndCloseFunds(find.text('RELIANCE'));
  });

  testWidgets('fund buy and sell close the sheet before opening orders', (
    tester,
  ) async {
    await tester.pumpWidget(TradingApp());
    await tester.pumpAndSettle();

    Future<void> verifyQuickTrade(String action) async {
      await tester.tap(find.text('RELIANCE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.byType(FundSheet), findsNothing);
      expect(find.byType(OrdersPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsExactly(2));
    }

    await verifyQuickTrade('Buy');
    await verifyQuickTrade('Sell');
  });
}
