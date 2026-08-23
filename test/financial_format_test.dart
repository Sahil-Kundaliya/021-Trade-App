import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialFormatter', () {
    test('formats prices with two decimals and grouping', () {
      expect(FinancialFormatter.price(1316), '₹1,316.00');
      expect(FinancialFormatter.price(1316.2), '₹1,316.20');
      expect(FinancialFormatter.price(101.234), '₹101.23');
    });

    test('formats change and percentage with signs and two decimals', () {
      expect(FinancialFormatter.change(3), '+3.00');
      expect(FinancialFormatter.change(-3.5), '-3.50');
      expect(FinancialFormatter.change(0), '0.00');
      expect(FinancialFormatter.percentage(0.2), '+0.20%');
      expect(FinancialFormatter.percentage(-0.2), '-0.20%');
      expect(FinancialFormatter.percentage(0), '0.00%');
      expect(FinancialFormatter.percentage(-0.000001), '0.00%');
      expect(FinancialFormatter.change(1.234), '+1.23');
      expect(FinancialFormatter.percentage(1.234), '+1.23%');
      expect(FinancialFormatter.change(-1.235), '-1.24');
      expect(FinancialFormatter.percentage(-1.235), '-1.24%');
    });

    test('normalizes negative zero', () {
      expect(FinancialFormatter.normalize(-0.004), 0);
      expect(FinancialFormatter.decimals(-0.000001), '0.00');
      expect(FinancialFormatter.displaySign(-0.000001), 0);
      expect(FinancialFormatter.displaySign(1.234, 1.23), 1);
      expect(FinancialFormatter.displaySign(-1.24, -1.24), -1);
    });
  });

  testWidgets('MarketPriceChange uses semantic colors and hides flat arrows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              MarketPriceChange(change: 3.05, changePercent: 0.23),
              MarketPriceChange(change: -3.05, changePercent: -0.23),
              MarketPriceChange(change: 0, changePercent: 0),
            ],
          ),
        ),
      ),
    );

    expect(find.text('+3.05 (+0.23%)'), findsOneWidget);
    expect(find.text('-3.05 (-0.23%)'), findsOneWidget);
    expect(find.text('0.00 (0.00%)'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });
}
