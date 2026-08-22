import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../account/data/mock_profile_data.dart';
import '../../../account/presentation/widgets/logout_tile.dart';
import '../../../account/presentation/widgets/profile_header.dart';
import '../../../account/presentation/widgets/profile_section.dart';
import '../../../account/presentation/widgets/profile_setting_tile.dart';
import '../../../account/presentation/widgets/profile_toggle_tile.dart';
import '../../../account/presentation/widgets/theme_setting_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _privacyModeEnabled = false;
  bool _appLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Profile'),
                  const SizedBox(height: AppSpacing.lg),
                  const ProfileHeader(profile: mockTraderProfile),
                  const SizedBox(height: AppSpacing.xxl),
                  ProfileSection(
                    title: 'Account',
                    children: const [
                      ProfileSettingTile(
                        icon: Icons.person_outline,
                        title: 'Personal Details',
                        subtitle: 'Name, email, phone and account information',
                      ),
                      ProfileSettingTile(
                        icon: Icons.account_balance_outlined,
                        title: 'Bank & Demat Details',
                        subtitle: 'Linked bank and Demat account',
                      ),
                      ProfileSettingTile(
                        icon: Icons.candlestick_chart_outlined,
                        title: 'Trading Segments',
                        subtitle: 'Equity, Futures & Options',
                      ),
                      ProfileSettingTile(
                        icon: Icons.description_outlined,
                        title: 'Documents & Reports',
                        subtitle: 'Statements, contract notes and reports',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProfileSection(
                    title: 'Preferences',
                    children: [
                      ThemeSettingTile(
                        selectedTheme: _selectedTheme,
                        onTap: _showThemePicker,
                      ),
                      ProfileToggleTile(
                        icon: Icons.visibility_off_outlined,
                        title: 'Privacy Mode',
                        subtitle: 'Hide sensitive portfolio and fund values',
                        value: _privacyModeEnabled,
                        onChanged: (value) {
                          setState(() => _privacyModeEnabled = value);
                        },
                      ),
                      const ProfileSettingTile(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notifications',
                        subtitle: 'Orders, price alerts and account activity',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProfileSection(
                    title: 'Security',
                    children: [
                      ProfileToggleTile(
                        icon: Icons.fingerprint,
                        title: 'Biometric / App Lock',
                        subtitle: 'Use Face ID, fingerprint or device lock',
                        value: _appLockEnabled,
                        onChanged: (value) {
                          setState(() => _appLockEnabled = value);
                        },
                      ),
                      const ProfileSettingTile(
                        icon: Icons.shield_outlined,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Add an extra layer of account security',
                        status: 'Enabled',
                        statusIsPositive: true,
                      ),
                      const ProfileSettingTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                      ),
                      const ProfileSettingTile(
                        icon: Icons.devices_outlined,
                        title: 'Active Sessions',
                        subtitle: 'Manage devices logged into your account',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const ProfileSection(
                    title: 'Trading & App',
                    children: [
                      ProfileSettingTile(
                        icon: Icons.tune_outlined,
                        title: 'Order Preferences',
                        subtitle: 'Default order and confirmation settings',
                      ),
                      ProfileSettingTile(
                        icon: Icons.show_chart,
                        title: 'Price Display Preferences',
                        subtitle: 'Market value and price display options',
                      ),
                      ProfileSettingTile(
                        icon: Icons.info_outline,
                        title: 'App Information',
                        value: 'Version 1.0.0',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const ProfileSection(
                    title: 'Support & Legal',
                    children: [
                      ProfileSettingTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'FAQs and customer support',
                      ),
                      ProfileSettingTile(
                        icon: Icons.report_outlined,
                        title: 'Report an Issue',
                      ),
                      ProfileSettingTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                      ),
                      ProfileSettingTile(
                        icon: Icons.gavel_outlined,
                        title: 'Terms & Conditions',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const LogoutTile(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showThemePicker() async {
    final selection = await showModalBottomSheet<ThemeMode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ThemePicker(selectedTheme: _selectedTheme),
    );

    if (selection != null && mounted) {
      setState(() => _selectedTheme = selection);
    }
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selectedTheme});

  final ThemeMode selectedTheme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Appearance', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose how the app should look. This preview setting is not persisted.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RadioGroup<ThemeMode>(
                groupValue: selectedTheme,
                onChanged: (selection) => Navigator.of(context).pop(selection),
                child: const Column(
                  children: [
                    _ThemeOption(
                      title: 'System default',
                      value: ThemeMode.system,
                    ),
                    _ThemeOption(title: 'Light', value: ThemeMode.light),
                    _ThemeOption(title: 'Dark', value: ThemeMode.dark),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.title, required this.value});

  final String title;
  final ThemeMode value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: value,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
    );
  }
}
