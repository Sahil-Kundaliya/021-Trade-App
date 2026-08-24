import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../account/data/mock_profile_data.dart';
import '../../../account/presentation/bloc/profile_bloc.dart';
import '../../../account/presentation/bloc/profile_event.dart';
import '../../../account/presentation/bloc/profile_state.dart';
import '../../../account/presentation/widgets/logout_tile.dart';
import '../../../account/presentation/widgets/profile_header.dart';
import '../../../account/presentation/widgets/profile_section.dart';
import '../../../account/presentation/widgets/profile_setting_tile.dart';
import '../../../account/presentation/widgets/profile_toggle_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.bloc,
    required this.themeMode,
    required this.onThemeChanged,
    required this.privacyMode,
    required this.notificationsEnabled,
    required this.notificationPermissionBlocked,
    required this.onPrivacyChanged,
    required this.onNotificationsChanged,
    this.navigator,
    super.key,
  });
  final ProfileBloc bloc;
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final bool privacyMode;
  final bool notificationsEnabled;
  final bool notificationPermissionBlocked;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: bloc,
    child: ProfileContent(
      navigator: navigator,
      themeMode: themeMode,
      onThemeChanged: onThemeChanged,
      privacyMode: privacyMode,
      notificationsEnabled: notificationsEnabled,
      notificationPermissionBlocked: notificationPermissionBlocked,
      onPrivacyChanged: onPrivacyChanged,
      onNotificationsChanged: onNotificationsChanged,
    ),
  );
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    required this.themeMode,
    required this.onThemeChanged,
    required this.privacyMode,
    required this.notificationsEnabled,
    required this.notificationPermissionBlocked,
    required this.onPrivacyChanged,
    required this.onNotificationsChanged,
    this.navigator,
    super.key,
  });
  final AppNavigator? navigator;
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final bool privacyMode;
  final bool notificationsEnabled;
  final bool notificationPermissionBlocked;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) => BlocConsumer<ProfileBloc, ProfileState>(
    listenWhen: (previous, current) =>
        previous.errorMessage != current.errorMessage &&
        current.errorMessage != null,
    listener: (context, state) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
    builder: (context, state) => Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: _ProfileSections(
                state: state,
                navigator: navigator,
                themeMode: themeMode,
                onThemeChanged: onThemeChanged,
                privacyMode: privacyMode,
                notificationsEnabled: notificationsEnabled,
                notificationPermissionBlocked: notificationPermissionBlocked,
                onPrivacyChanged: onPrivacyChanged,
                onNotificationsChanged: onNotificationsChanged,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ProfileSections extends StatelessWidget {
  const _ProfileSections({
    required this.state,
    required this.navigator,
    required this.themeMode,
    required this.onThemeChanged,
    required this.privacyMode,
    required this.notificationsEnabled,
    required this.notificationPermissionBlocked,
    required this.onPrivacyChanged,
    required this.onNotificationsChanged,
  });
  final ProfileState state;
  final AppNavigator? navigator;
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final bool privacyMode;
  final bool notificationsEnabled;
  final bool notificationPermissionBlocked;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final preferences = state.preferences;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Profile',
          level: AppSectionHeaderLevel.page,
        ),
        const SizedBox(height: AppSpacing.lg),
        const ProfileHeader(profile: mockTraderProfile),
        const SizedBox(height: AppSpacing.lg),
        const ProfileSection(
          title: 'Account',
          children: [
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
        const SizedBox(height: AppSpacing.lg),
        ProfileSection(
          title: 'Preferences',
          children: [
            ProfileSettingTile(
              icon: Icons.brightness_6_outlined,
              title: 'Theme',
              subtitle: 'Change app appearance',
              value: _themeLabel(themeMode),
              onTap: () => _showThemePicker(context),
            ),
            ProfileToggleTile(
              icon: Icons.visibility_off_outlined,
              title: 'Privacy Mode',
              subtitle: 'Hide sensitive portfolio values',
              value: privacyMode,
              onChanged: onPrivacyChanged,
            ),
            ProfileToggleTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: notificationPermissionBlocked
                  ? 'Permission disabled in system settings'
                  : 'Local notifications for order updates',
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const ProfileSection(
          title: 'Security',
          children: [
            ProfileSettingTile(
              icon: Icons.fingerprint,
              title: 'Biometric / App Lock',
              subtitle: 'Requires device authentication infrastructure',
            ),
            ProfileSettingTile(
              icon: Icons.shield_outlined,
              title: 'Two-Factor Authentication',
              subtitle: 'Requires account security infrastructure',
            ),
            ProfileSettingTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
            ),
            ProfileSettingTile(
              icon: Icons.devices_outlined,
              title: 'Active Sessions',
              subtitle: 'Manage devices logged into your account',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileSection(
          title: 'Trading & App',
          children: [
            ProfileSettingTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Funds',
              subtitle: 'Add money to your trading account',
              onTap: navigator?.openAccountFunds,
            ),
            ProfileSettingTile(
              icon: Icons.receipt_long_outlined,
              title: 'Order Book',
              subtitle: 'Open and closed orders',
              onTap: navigator?.openOrderBook,
            ),
            ProfileSettingTile(
              icon: Icons.tune_outlined,
              title: 'Order Preferences',
              subtitle: 'Default side, order type and product',
              value: _orderSummary(preferences),
              onTap: () => _showOrderPreferences(context, preferences),
            ),
            ProfileSettingTile(
              icon: Icons.show_chart,
              title: 'Price Display Preferences',
              subtitle: 'Market value and price display options',
              value: _priceLabel(preferences.priceDisplayMode),
              onTap: () =>
                  _showPriceDisplay(context, preferences.priceDisplayMode),
            ),
            ProfileSettingTile(
              icon: Icons.info_outline,
              title: 'App Information',
              value: 'Version 1.0.0',
              onTap: () => _showAppInformation(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileSection(
          title: 'Support & Legal',
          children: [
            const ProfileSettingTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and customer support',
            ),
            const ProfileSettingTile(
              icon: Icons.report_outlined,
              title: 'Report an Issue',
            ),
            ProfileSettingTile(
              icon: Icons.policy_outlined,
              title: 'Licence & Regulatory Information',
              onTap: navigator?.openLicenceInformation,
            ),
            const ProfileSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
            ),
            const ProfileSettingTile(
              icon: Icons.gavel_outlined,
              title: 'Terms & Conditions',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const LogoutTile(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final selection = await showModalBottomSheet<AppThemeMode>(
      context: context,
      builder: (_) => _ChoiceSheet<AppThemeMode>(
        title: 'Theme',
        selected: themeMode,
        options: const {
          AppThemeMode.system: 'System',
          AppThemeMode.light: 'Light',
          AppThemeMode.dark: 'Dark',
        },
      ),
    );
    if (selection != null) onThemeChanged(selection);
  }

  Future<void> _showPriceDisplay(
    BuildContext context,
    PriceDisplayMode selected,
  ) async {
    final selection = await showModalBottomSheet<PriceDisplayMode>(
      context: context,
      builder: (_) => _ChoiceSheet<PriceDisplayMode>(
        title: 'Price Display Preferences',
        selected: selected,
        options: const {
          PriceDisplayMode.absoluteAndPercent: 'Price Change + %',
          PriceDisplayMode.percentOnly: 'Percentage Only',
          PriceDisplayMode.absoluteOnly: 'Absolute Change Only',
        },
      ),
    );
    if (selection != null && context.mounted) {
      context.read<ProfileBloc>().add(ProfilePriceDisplayChanged(selection));
    }
  }

  Future<void> _showOrderPreferences(
    BuildContext context,
    AppPreferences value,
  ) async {
    final result = await showModalBottomSheet<_OrderSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OrderPreferencesSheet(preferences: value),
    );
    if (result != null && context.mounted) {
      context.read<ProfileBloc>().add(
        ProfileOrderPreferencesChanged(
          side: result.side,
          orderType: result.orderType,
          productType: result.productType,
        ),
      );
    }
  }

  void _showAppInformation(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('App Information'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: 'App Name', value: '021 Trade'),
          _InfoLine(label: 'Version', value: '1.0.0'),
          _InfoLine(label: 'Build Number', value: '1'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.selected,
    required this.options,
  });
  final String title;
  final T selected;
  final Map<T, String> options;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title.toUpperCase(), style: context.appTextStyles.tableHeader),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<T>(
            groupValue: selected,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              children: [
                for (final option in options.entries)
                  RadioListTile<T>(
                    value: option.key,
                    title: Text(option.value),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _OrderPreferencesSheet extends StatelessWidget {
  const _OrderPreferencesSheet({required this.preferences});
  final AppPreferences preferences;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => _OrderPreferencesCubit(
      _OrderSelection(
        preferences.defaultOrderSide,
        preferences.defaultOrderType,
        preferences.defaultProductType,
      ),
    ),
    child: BlocBuilder<_OrderPreferencesCubit, _OrderSelection>(
      builder: (context, selection) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ORDER PREFERENCES',
                style: context.appTextStyles.tableHeader,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SegmentedField<DefaultOrderSide>(
                label: 'Default Side',
                selected: {selection.side},
                values: const {
                  DefaultOrderSide.buy: 'Buy',
                  DefaultOrderSide.sell: 'Sell',
                },
                onChanged: context.read<_OrderPreferencesCubit>().sideChanged,
              ),
              _SegmentedField<DefaultOrderType>(
                label: 'Order Type',
                selected: {selection.orderType},
                values: const {
                  DefaultOrderType.market: 'Market',
                  DefaultOrderType.limit: 'Limit',
                },
                onChanged: context
                    .read<_OrderPreferencesCubit>()
                    .orderTypeChanged,
              ),
              _SegmentedField<DefaultProductType>(
                label: 'Product',
                selected: {selection.productType},
                values: const {
                  DefaultProductType.delivery: 'Delivery',
                  DefaultProductType.intraday: 'Intraday',
                },
                onChanged: context
                    .read<_OrderPreferencesCubit>()
                    .productTypeChanged,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => Navigator.pop(context, selection),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SegmentedField<T> extends StatelessWidget {
  const _SegmentedField({
    required this.label,
    required this.selected,
    required this.values,
    required this.onChanged,
  });
  final String label;
  final Set<T> selected;
  final Map<T, String> values;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<T>(
          segments: [
            for (final value in values.entries)
              ButtonSegment(value: value.key, label: Text(value.value)),
          ],
          selected: selected,
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: context.appTextStyles.bodyMedium),
      ],
    ),
  );
}

final class _OrderSelection {
  const _OrderSelection(this.side, this.orderType, this.productType);
  final DefaultOrderSide side;
  final DefaultOrderType orderType;
  final DefaultProductType productType;
}

final class _OrderPreferencesCubit extends Cubit<_OrderSelection> {
  _OrderPreferencesCubit(super.initialState);
  void sideChanged(DefaultOrderSide value) =>
      emit(_OrderSelection(value, state.orderType, state.productType));
  void orderTypeChanged(DefaultOrderType value) =>
      emit(_OrderSelection(state.side, value, state.productType));
  void productTypeChanged(DefaultProductType value) =>
      emit(_OrderSelection(state.side, state.orderType, value));
}

String _themeLabel(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => 'System',
  AppThemeMode.light => 'Light',
  AppThemeMode.dark => 'Dark',
};
String _priceLabel(PriceDisplayMode mode) => switch (mode) {
  PriceDisplayMode.absoluteAndPercent => 'Change + %',
  PriceDisplayMode.percentOnly => 'Percentage',
  PriceDisplayMode.absoluteOnly => 'Absolute',
};
String _orderSummary(AppPreferences value) =>
    '${value.defaultOrderSide == DefaultOrderSide.buy ? 'Buy' : 'Sell'} · ${value.defaultOrderType == DefaultOrderType.market ? 'Market' : 'Limit'}';
