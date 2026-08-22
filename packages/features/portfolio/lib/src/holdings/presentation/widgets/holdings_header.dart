import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../bloc/holdings_sort.dart';

class HoldingsHeader extends StatelessWidget {
  const HoldingsHeader({
    required this.sort,
    required this.onSortChanged,
    super.key,
  });

  final HoldingsSort sort;
  final ValueChanged<HoldingsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: 'Holdings',
      trailing: Semantics(
        label:
            'Sorted by ${sort.label}, '
            '${sort.descending ? 'descending' : 'ascending'}',
        child: PopupMenuButton<HoldingsSort>(
          onSelected: onSortChanged,
          itemBuilder: (_) => HoldingsSort.values
              .map(
                (value) => PopupMenuItem(
                  value: value,
                  child: Text('${value.label} ${value.descending ? '↓' : '↑'}'),
                ),
              )
              .toList(growable: false),
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
                    sort.label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    sort.descending ? Icons.arrow_downward : Icons.arrow_upward,
                    size: AppSizes.iconXs,
                    color: context.appColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
