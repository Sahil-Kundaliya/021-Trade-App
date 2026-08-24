import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initial value is static and a new up tick pulses text color', (
    tester,
  ) async {
    await tester.pumpWidget(_app(updateId: 1, label: '100.00'));
    expect(_textColor(tester), lightAppColors.textPrimary);

    await tester.pumpWidget(_app(updateId: 2, label: '101.00'));
    expect(_textColor(tester), lightAppColors.priceUp);
    expect(find.text('101.00'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LiveValueFlash),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );

    await tester.pump(AppMotion.liveValuePulse);
    expect(_textColor(tester), lightAppColors.textPrimary);
  });

  testWidgets('unrelated rebuild does not replay and flat ticks do not pulse', (
    tester,
  ) async {
    await tester.pumpWidget(_app(updateId: 1));
    await tester.pumpWidget(_app(updateId: 2));
    await tester.pump(AppMotion.liveValuePulse);

    await tester.pumpWidget(_app(updateId: 2, label: 'unrelated'));
    expect(_textColor(tester), lightAppColors.textPrimary);

    await tester.pumpWidget(
      _app(updateId: 3, direction: LiveValueDirection.flat),
    );
    expect(_textColor(tester), lightAppColors.textPrimary);
  });

  testWidgets('rapid reversal immediately replaces the active direction', (
    tester,
  ) async {
    await tester.pumpWidget(_app(updateId: 1, label: '100.00'));
    await tester.pumpWidget(_app(updateId: 2, label: '101.00'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(
      _app(
        updateId: 3,
        direction: LiveValueDirection.down,
        label: '100.50',
      ),
    );
    expect(_textColor(tester), lightAppColors.priceDown);
    expect(find.text('100.50'), findsOneWidget);
  });

  testWidgets('privacy and reduced motion suppress directional cues', (
    tester,
  ) async {
    await tester.pumpWidget(_app(updateId: 1, privacy: true));
    await tester.pumpWidget(_app(updateId: 2, privacy: true));
    expect(_textColor(tester), lightAppColors.textPrimary);

    await tester.pumpWidget(_app(updateId: 3, disableAnimations: true));
    expect(_textColor(tester), lightAppColors.textPrimary);
  });
}

Widget _app({
  required int updateId,
  LiveValueDirection direction = LiveValueDirection.up,
  bool privacy = false,
  bool disableAnimations = false,
  String label = '101.00',
}) => MaterialApp(
  theme: AppTheme.light,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: PrivacyModeScope(
      enabled: privacy,
      child: Scaffold(
        body: LiveValueFlash(
          direction: direction,
          updateId: updateId,
          normalColor: lightAppColors.textPrimary,
          builder: (color) => Text(label, style: TextStyle(color: color)),
        ),
      ),
    ),
  ),
);

Color? _textColor(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byType(LiveValueFlash),
      matching: find.byType(Text),
    ),
  );
  return text.style?.color;
}
