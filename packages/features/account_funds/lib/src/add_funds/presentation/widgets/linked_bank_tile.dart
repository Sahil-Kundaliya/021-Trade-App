import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/linked_bank_account.dart';

class LinkedBankTile extends StatelessWidget {
  const LinkedBankTile({
    required this.bank,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final LinkedBankAccount bank;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: context.motionDuration(AppMotion.fast),
      curve: AppMotionCurves.standard,
      child: Material(
        color: context.appColors.surface,
        child: InkWell(
          onTap: () => onSelected(bank.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: AppSizes.iconSm,
                    color: selected
                        ? context.appColors.selection
                        : context.appColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.bankName,
                          style: context.appTextStyles.bodyMedium.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${bank.maskedNumber}  ·  ${bank.accountTypeLabel}',
                          style: context.appTextStyles.caption.copyWith(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bank.isPrimary) ...[
                    const SizedBox(width: AppSpacing.sm),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.appColors.primaryContainer,
                        borderRadius: AppRadius.xsBorderRadius,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Text(
                          'PRIMARY',
                          style: context.appTextStyles.statusLabel.copyWith(
                            color: context.appColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
