import 'package:flutter/material.dart';

import '../../theme/tokens/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
