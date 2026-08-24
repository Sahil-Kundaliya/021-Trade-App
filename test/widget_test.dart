import 'package:account_funds/account_funds.dart';
import 'package:core_data/core_data.dart';
import 'package:fund/fund.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';
import 'package:orderbook/orderbook.dart';
import 'package:profile/profile.dart';
import 'package:search/search.dart';
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
    Future<void> pumpNavigation() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }

    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.goToWatchlist();
    await tester.pumpAndSettle();
    expect(find.text('Watchlist'), findsExactly(2));

    app.navigator.goToPortfolio();
    await pumpNavigation();
    expect(find.text('Portfolio'), findsExactly(2));

    app.navigator.goToProfile();
    await pumpNavigation();
    expect(find.text('Profile'), findsExactly(2));

    app.navigator.goToDashboard();
    await pumpNavigation();
    expect(find.text('Dashboard'), findsExactly(2));

    app.navigator.openOrders(
      fundId: 'RELIANCE_EQ',
      exchange: TradeExchange.nse,
    );
    await pumpNavigation();
    expect(find.byType(OrdersScreen), findsOneWidget);

    await app.navigator.pop();
    await pumpNavigation();
    expect(find.byType(OrdersScreen), findsNothing);

    app.navigator.openOrderBook();
    await pumpNavigation();
    expect(find.byType(OrderBookScreen), findsOneWidget);

    await app.navigator.pop();
    await pumpNavigation();
    expect(find.byType(OrderBookScreen), findsNothing);

    app.navigator.openAccountFunds();
    await pumpNavigation();
    expect(find.byType(AccountFundsScreen), findsOneWidget);
    expect(find.text('Add Funds'), findsOneWidget);

    await app.navigator.pop();
    await pumpNavigation();
    expect(find.byType(AccountFundsScreen), findsNothing);

    app.navigator.openFund(fundId: 'RELIANCE_EQ', exchange: TradeExchange.nse);
    await pumpNavigation();
    expect(find.byType(FundSheet), findsOneWidget);
    expect(find.text('BUY'), findsOneWidget);
    expect(find.text('SELL'), findsOneWidget);
    expect(
      tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
      isFalse,
    );

    await tester.binding.handlePopRoute();
    await pumpNavigation();
    expect(find.byType(FundSheet), findsNothing);
    expect(find.text('Dashboard'), findsExactly(2));
  });

  testWidgets('profile opens Order Book through the navigation contract', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.goToProfile();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Order Book'));
    await tester.tap(find.text('Order Book'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderBookScreen), findsOneWidget);
    expect(find.text('No open orders'), findsOneWidget);
  });

  testWidgets('profile opens Account Funds through the navigation contract', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.goToProfile();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Funds'));
    await tester.tap(find.text('Funds'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountFundsScreen), findsOneWidget);
    expect(find.text('Add Funds'), findsOneWidget);
    expect(find.text('Available Funds'), findsOneWidget);
    expect(find.text('₹0.00'), findsOneWidget);
    expect(find.text('HDFC Bank'), findsOneWidget);
    expect(find.textContaining('4321'), findsOneWidget);
    expect(find.text('PRIMARY'), findsOneWidget);
    expect(find.text('Add New Bank Account'), findsOneWidget);

    await app.navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(AccountFundsScreen), findsNothing);
    expect(find.text('Profile'), findsExactly(2));
  });

  testWidgets('profile opens fictional licence information and returns', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.goToProfile();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Licence & Regulatory Information'));
    await tester.tap(find.text('Licence & Regulatory Information'));
    await tester.pumpAndSettle();

    expect(find.byType(LicenceScreen), findsOneWidget);
    expect(find.text('Demo Regulatory Information'), findsOneWidget);
    expect(find.text('DEMO-INZ000000000'), findsOneWidget);
    expect(find.text('NOT A REAL REGISTRATION'), findsOneWidget);

    await app.navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(LicenceScreen), findsNothing);
    expect(find.text('Profile'), findsExactly(2));
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
      expect(find.byTooltip('Close fund details'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(FundSheet), findsNothing);
    }

    await openAndCloseFunds(find.text('RELIANCE'));

    await tester.tap(find.text('Watchlist').last);
    await tester.pumpAndSettle();
    await openAndCloseFunds(find.text('RELIANCE'));

    await tester.tap(find.text('Portfolio').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('RELIANCE'), findsNothing);
  });

  testWidgets('Dashboard, Watchlist and Portfolio open the same Search route', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    Future<void> openAndCloseSearch() async {
      await tester.tap(find.byTooltip('Search funds'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.text('TRADING FUNDS'), findsOneWidget);
      await app.navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byType(SearchScreen), findsNothing);
    }

    await openAndCloseSearch();
    app.navigator.goToWatchlist();
    await tester.pumpAndSettle();
    await openAndCloseSearch();
    app.navigator.goToPortfolio();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await openAndCloseSearch();
  });

  testWidgets('Search preserves a BSE listing when opening Fund Details', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.openSearch();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'REL');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('SEARCH RESULTS'), findsOneWidget);
    final bseResult = find.text('BSE • Equity');
    expect(bseResult, findsOneWidget);
    await tester.tap(bseResult);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FundSheet), findsOneWidget);
    expect(find.text('BSE'), findsWidgets);
  });

  testWidgets('fund instrument details pin after the sheet fully expands', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.openFund(fundId: 'RELIANCE_EQ', exchange: TradeExchange.nse);
    await tester.pumpAndSettle();

    final fundSheet = find.byType(FundSheet);
    final scroller = find.descendant(
      of: fundSheet,
      matching: find.byType(CustomScrollView),
    );
    final stickyHeader = find.byKey(const Key('fund-instrument-sticky-header'));

    await tester.drag(scroller, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.drag(scroller, const Offset(0, -200));
    await tester.pumpAndSettle();
    final pinnedTop = tester.getTopLeft(stickyHeader).dy;
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: fundSheet, matching: find.byType(Scrollable)),
    );
    final firstOffset = scrollable.position.pixels;

    await tester.drag(scroller, const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(firstOffset));
    expect(tester.getTopLeft(stickyHeader).dy, closeTo(pinnedTop, 1));
  });

  testWidgets('fund buy and sell close the sheet before opening orders', (
    tester,
  ) async {
    await tester.pumpWidget(TradingApp());
    await tester.pumpAndSettle();

    Future<void> verifyQuickTrade(String action) async {
      await tester.ensureVisible(find.text('RELIANCE'));
      await tester.tap(find.text('RELIANCE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.byType(FundSheet), findsNothing);
      expect(find.byType(OrdersScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsExactly(2));
    }

    await verifyQuickTrade('BUY');
    await verifyQuickTrade('SELL');
  });

  testWidgets('future and option IDs render their own dynamic fund details', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.openFund(
      fundId: 'TCS_FUT_20260825',
      exchange: TradeExchange.nse,
    );
    await tester.pumpAndSettle();
    expect(find.text('TCS AUG FUT'), findsOneWidget);
    expect(find.text('Future'), findsOneWidget);
    expect(find.text('Expiry'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    app.navigator.openFund(
      fundId: 'SBIN_OPT_1050_CE_20260825',
      exchange: TradeExchange.nse,
    );
    await tester.pumpAndSettle();
    expect(find.text('SBIN 1050 CE'), findsOneWidget);
    expect(find.text('Options'), findsWidgets);
    expect(find.text('Strike'), findsOneWidget);
    expect(find.text('Implied Volatility'), findsOneWidget);
    await tester.ensureVisible(find.text('PRICE HISTORY'));
    await tester.pumpAndSettle();
    expect(find.text('1M'), findsOneWidget);
    expect(find.text('3M'), findsOneWidget);
  });

  testWidgets('fund sheet adds its current fund to persisted Default', (
    tester,
  ) async {
    final app = TradingApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.navigator.openFund(fundId: 'AXISBANK_EQ', exchange: TradeExchange.nse);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add to Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('Default'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Added to Default'), findsOneWidget);
    expect(find.byTooltip('Remove from Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    app.navigator.openFund(fundId: 'AXISBANK_EQ', exchange: TradeExchange.nse);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Remove from Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from Watchlist'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add to Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsNothing);
  });
}
