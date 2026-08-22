import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WatchlistHeader extends StatelessWidget {
  const WatchlistHeader({this.onSettingsPressed, super.key});

  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Watchlist', style: context.textTheme.titleLarge)),
        AppIconButton(
          tooltip: 'Watchlist settings',
          onPressed: onSettingsPressed ?? _noOp,
          icon: Icon(
            Icons.settings_outlined,
            size: AppSizes.iconMd,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

void _noOp() {}
