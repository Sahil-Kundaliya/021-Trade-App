import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class FundBreakdownRow extends StatelessWidget {
  const FundBreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final valueStyle = emphasized
        ? context.appTextStyles.marketValueMedium
        : context.appTextStyles.tableValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  (emphasized
                          ? context.textTheme.bodyMedium
                          : context.textTheme.bodySmall)
                      ?.copyWith(color: context.appColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.end,
            style: valueStyle.copyWith(
              color: valueColor ?? context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
