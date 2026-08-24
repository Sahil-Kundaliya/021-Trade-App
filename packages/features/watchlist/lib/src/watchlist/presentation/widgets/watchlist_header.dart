import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WatchlistHeader extends StatelessWidget {
  const WatchlistHeader({this.onSearch, this.onSettings, super.key});

  final VoidCallback? onSearch;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) => AppSectionHeader(
    title: 'Watchlist',
    level: AppSectionHeaderLevel.page,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          tooltip: 'Watchlist settings',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined, size: AppSizes.iconXs),
        ),
        AppIconButton(
          tooltip: 'Search funds',
          onPressed: onSearch,
          icon: const Icon(Icons.search, size: AppSizes.iconXs),
        ),
      ],
    ),
  );
}
