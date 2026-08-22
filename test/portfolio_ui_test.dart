import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/portfolio.dart';
import 'package:portfolio/src/holdings/presentation/widgets/holdings_list.dart';

void main() {
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

  testWidgets('shows the portfolio summary and static holdings', (
    tester,
  ) async {
    await pumpPortfolio(tester);

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Portfolio Value'), findsOneWidget);
    expect(find.text('\u20B94,82,640.50'), findsNWidgets(2));
    expect(find.text('+\u20B932,640.50'), findsOneWidget);
    expect(find.text('+7.25%'), findsOneWidget);
    expect(find.text('Unrealised Gain'), findsOneWidget);
    expect(find.text('Total Invested'), findsOneWidget);
    expect(find.text('\u20B94,50,000.00'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);
    expect(find.text('P&L'), findsWidgets);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text('Reliance Industries'), findsOneWidget);
    expect(find.text('+\u20B96,595.00'), findsOneWidget);
  });

  testWidgets('renders safely on a narrow screen and in dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPortfolio(tester, themeMode: ThemeMode.dark);

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
