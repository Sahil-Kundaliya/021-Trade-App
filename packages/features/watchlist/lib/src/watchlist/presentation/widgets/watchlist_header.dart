import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WatchlistHeader extends StatelessWidget {
  const WatchlistHeader({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) => AppSectionHeader(
    title: 'Watchlist',
    level: AppSectionHeaderLevel.page,
    trailing: AppIconButton(
      tooltip: 'Search funds',
      onPressed: onSearch,
      icon: const Icon(Icons.search, size: AppSizes.iconSm),
    ),
  );
}
