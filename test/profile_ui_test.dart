import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(_ProfileHarness(initialThemeMode: themeMode));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the complete static trading profile', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Client ID: TRD102458'), findsOneWidget);
    expect(find.text('rahul.sharma@example.com'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Available Funds'), findsOneWidget);
    expect(find.text('₹12,500.00'), findsOneWidget);

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
      'Order Book',
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
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });

  testWidgets('theme picker changes the application theme value', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.ensureVisible(find.text('Theme'));
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('THEME'), findsOneWidget);
    expect(
      tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
      isTrue,
    );
    expect(
      tester.getSize(find.byType(BottomSheet)).height,
      lessThan(tester.view.physicalSize.height / tester.view.devicePixelRatio),
    );
    expect(find.text('System'), findsWidgets);
    expect(find.text('Light'), findsWidgets);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.text('THEME'), findsNothing);
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
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(tester.takeException(), isNull, reason: 'Failed at $width px');
    }
  });
}

class _ProfileHarness extends StatefulWidget {
  const _ProfileHarness({required this.initialThemeMode});
  final ThemeMode initialThemeMode;

  @override
  State<_ProfileHarness> createState() => _ProfileHarnessState();
}

class _ProfileHarnessState extends State<_ProfileHarness> {
  AppThemeMode mode = AppThemeMode.system;
  bool privacyMode = false;
  bool notificationsEnabled = false;
  late ThemeMode renderedTheme = widget.initialThemeMode;
  late final ProfileBloc bloc = ProfileBloc(
    ProfilePreferencesRepositoryImpl(
      AppPreferencesRepository(_MemoryPreferencesApi()),
    ),
    const _ProfileFundsRepository(),
  )..add(const ProfileStarted());

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: renderedTheme,
    home: ProfilePage(
      bloc: bloc,
      themeMode: mode,
      privacyMode: privacyMode,
      notificationsEnabled: notificationsEnabled,
      notificationPermissionBlocked: false,
      onPrivacyChanged: (value) => setState(() => privacyMode = value),
      onNotificationsChanged: (value) =>
          setState(() => notificationsEnabled = value),
      onThemeChanged: (value) => setState(() {
        mode = value;
        renderedTheme = switch (value) {
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
        };
      }),
    ),
  );
}

final class _MemoryPreferencesApi implements AppPreferencesLocalApi {
  AppPreferences? value;

  @override
  Future<AppPreferences?> read() async => value;

  @override
  Future<void> write(AppPreferences preferences) async {
    value = preferences;
  }
}

final class _ProfileFundsRepository implements ProfileFundsRepository {
  const _ProfileFundsRepository();

  @override
  Future<double> getAvailableBalance() async => 12500;

  @override
  Stream<double> watchAvailableBalance() => const Stream.empty();
}
