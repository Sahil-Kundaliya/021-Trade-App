import 'package:flutter/material.dart';
import 'package:core_ui/src/spacing/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: AppSpacing.cardPadding, child: child),
    );
  }
}
