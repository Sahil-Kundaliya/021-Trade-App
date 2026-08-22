import 'package:flutter/material.dart';

import 'profile_setting_tile.dart';

class ThemeSettingTile extends StatelessWidget {
  const ThemeSettingTile({
    required this.selectedTheme,
    required this.onTap,
    super.key,
  });

  final ThemeMode selectedTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingTile(
      icon: Icons.brightness_6_outlined,
      title: 'Theme',
      subtitle: 'Change app appearance',
      value: _labelFor(selectedTheme),
      onTap: onTap,
    );
  }

  static String _labelFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
