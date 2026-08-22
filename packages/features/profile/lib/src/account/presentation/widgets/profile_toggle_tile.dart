import 'package:flutter/material.dart';

import 'profile_setting_tile.dart';

class ProfileToggleTile extends StatelessWidget {
  const ProfileToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      showChevron: false,
      onTap: () => onChanged(!value),
      trailing: Semantics(
        label: title,
        toggled: value,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
