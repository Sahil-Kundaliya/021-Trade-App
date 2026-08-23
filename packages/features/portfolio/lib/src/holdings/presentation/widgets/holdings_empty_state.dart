import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HoldingsEmptyState extends StatelessWidget {
  const HoldingsEmptyState({this.onExplore, super.key});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No holdings',
      description: 'Your successfully executed buy orders will appear here.',
      icon: Icons.pie_chart_outline,
      action: onExplore == null
          ? null
          : AppButton(
              label: 'Explore',
              leadingIcon: const Icon(Icons.explore_outlined),
              onPressed: onExplore,
            ),
    );
  }
}
