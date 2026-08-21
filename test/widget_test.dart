import 'package:fund/fund.dart';
import 'package:orders/orders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_two_one_trade_assignment/app/app.dart';

void main() {
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
    expect(find.byType(FundPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FundPage), findsNothing);
    expect(find.text('Dashboard'), findsExactly(2));
  });
}
