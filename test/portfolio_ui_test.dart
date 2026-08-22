import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/portfolio.dart';
import 'package:portfolio/src/holdings/presentation/widgets/holdings_list.dart';

import 'helpers/test_trading_api.dart';

void main() {
  setUpAll(installImmediateTradingApi);

  Future<void> finishLoading(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  Future<void> pumpPortfolio(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const PortfolioPage(),
      ),
    );
  }

  testWidgets('shows the portfolio summary and dataset holdings', (
    tester,
  ) async {
    await pumpPortfolio(tester);
    await finishLoading(tester);

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Portfolio Value'), findsOneWidget);
    expect(find.text('\u20B97,39,040.00'), findsNWidgets(2));
    expect(find.text('+\u20B910,775.00'), findsOneWidget);
    expect(find.text('+1.48%'), findsOneWidget);
    expect(find.text('Unrealised Gain'), findsOneWidget);
    expect(find.text('Total Invested'), findsOneWidget);
    expect(find.text('\u20B97,28,265.00'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);
    expect(find.text('P&L'), findsWidgets);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('+\u20B91,500.00'), findsOneWidget);
  });

  testWidgets('renders safely on a narrow screen and in dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPortfolio(tester, themeMode: ThemeMode.dark);
    await finishLoading(tester);

    expect(find.text('RELIANCE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the empty holdings state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: HoldingsList(holdings: [])),
      ),
    );

    expect(find.text('No holdings yet'), findsOneWidget);
    expect(
      find.text('Your purchased stocks will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
