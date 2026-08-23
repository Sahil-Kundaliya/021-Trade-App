import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('portfolio scope does not mask values outside portfolio', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            SensitiveValueText(
              'Dashboard ₹1,316.20',
              type: SensitiveValueType.currency,
            ),
            PrivacyModeScope(
              enabled: true,
              child: SensitiveValueText(
                'Portfolio ₹4,52,310.50',
                type: SensitiveValueType.currency,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Dashboard ₹1,316.20'), findsOneWidget);
    expect(find.text(PrivacyMask.currency), findsOneWidget);
    expect(find.text('Portfolio ₹4,52,310.50'), findsNothing);
  });

  testWidgets('sensitive values react immediately without changing data', (
    tester,
  ) async {
    Future<void> pump(bool private) => tester.pumpWidget(
      MaterialApp(
        home: PrivacyModeScope(
          enabled: private,
          child: const Scaffold(
            body: Column(
              children: [
                Text('RELIANCE'),
                SensitiveValueText(
                  '₹1,316.20',
                  type: SensitiveValueType.currency,
                ),
                SensitiveValueText(
                  '+0.19%',
                  type: SensitiveValueType.percentage,
                ),
                SensitiveValueText(
                  '10 Qty',
                  type: SensitiveValueType.quantity,
                  maskedValue: '•••• Qty',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await pump(false);
    expect(find.text('₹1,316.20'), findsOneWidget);
    expect(find.text('+0.19%'), findsOneWidget);
    expect(find.text('10 Qty'), findsOneWidget);

    await pump(true);
    expect(find.text('RELIANCE'), findsOneWidget);
    expect(find.text(PrivacyMask.currency), findsOneWidget);
    expect(find.text(PrivacyMask.percentage), findsOneWidget);
    expect(find.text('•••• Qty'), findsOneWidget);

    await pump(false);
    expect(find.text('₹1,316.20'), findsOneWidget);
  });
}
