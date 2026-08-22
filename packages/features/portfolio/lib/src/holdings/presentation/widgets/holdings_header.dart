import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HoldingsHeader extends StatelessWidget {
  const HoldingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: 'Holdings',
      trailing: Semantics(
        label: 'Sorted by profit and loss, descending',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border.all(color: context.appColors.border),
            borderRadius: AppRadius.smBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'P&L',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_downward,
                  size: AppSizes.iconXs,
                  color: context.appColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
