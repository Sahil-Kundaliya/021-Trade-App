import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/account_funds_money.dart';

class QuickAmountSelector extends StatelessWidget {
  const QuickAmountSelector({
    required this.selectedAmount,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final double? selectedAmount;
  final ValueChanged<double> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final amount in AccountFundsMoney.quickAddRupees)
          _QuickAmountChip(
            amount: amount,
            selected:
                selectedAmount != null &&
                AccountFundsMoney.toPaise(selectedAmount!) ==
                    AccountFundsMoney.toPaise(amount),
            enabled: enabled,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.amount,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final double amount;
  final bool selected;
  final bool enabled;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.controlCompact,
      child: OutlinedButton(
        onPressed: enabled ? () => onSelected(amount) : null,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          minimumSize: const Size(0, AppSizes.controlCompact),
          foregroundColor: selected
              ? context.appColors.selection
              : context.appColors.textPrimary,
          side: BorderSide(
            color: selected
                ? context.appColors.selection
                : context.appColors.border,
          ),
          backgroundColor: selected
              ? context.appColors.selectionContainer
              : context.appColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smBorderRadius,
          ),
          textStyle: context.appTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text('+${FinancialFormatter.price(amount)}'),
      ),
    );
  }
}
