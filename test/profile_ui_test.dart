import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const ProfilePage(),
      ),
    );
  }

  testWidgets('shows the complete static trading profile', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Client ID: TRD102458'), findsOneWidget);
    expect(find.text('rahul.sharma@example.com'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    for (final section in [
      'ACCOUNT',
      'PREFERENCES',
      'SECURITY',
      'TRADING & APP',
      'SUPPORT & LEGAL',
    ]) {
      expect(find.text(section), findsOneWidget);
    }

    for (final setting in [
      'Personal Details',
      'Bank & Demat Details',
      'Trading Segments',
      'Documents & Reports',
      'Theme',
      'Privacy Mode',
      'Notifications',
      'Biometric / App Lock',
      'Two-Factor Authentication',
      'Change Password',
      'Active Sessions',
      'Order Preferences',
      'Price Display Preferences',
      'App Information',
      'Help & Support',
      'Report an Issue',
      'Privacy Policy',
      'Terms & Conditions',
      'Log Out',
    ]) {
      expect(find.text(setting), findsOneWidget);
    }

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });

  testWidgets('theme picker changes presentation-only selected value', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsNothing);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('mock toggles can change visual state locally', (tester) async {
    await pumpProfile(tester);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    expect(tester.widget<Switch>(switches.first).value, isFalse);

    await tester.ensureVisible(find.text('Privacy Mode'));
    await tester.tap(find.text('Privacy Mode'));
    await tester.pump();

    expect(tester.widget<Switch>(switches.first).value, isTrue);
  });

  testWidgets('keeps trailing controls responsive across device widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final width in [280.0, 320.0, 600.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 900);
      await pumpProfile(tester, themeMode: ThemeMode.dark);

      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(tester.takeException(), isNull, reason: 'Failed at $width px');
    }
  });
}
