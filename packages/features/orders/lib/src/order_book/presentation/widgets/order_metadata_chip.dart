import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrderMetadataChip extends StatelessWidget {
  const OrderMetadataChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: AppRadius.xsBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
