import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HoldingsEmptyState extends StatelessWidget {
  const HoldingsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No holdings yet',
      description: 'Your purchased stocks will appear here.',
      icon: Icons.pie_chart_outline,
    );
  }
}
