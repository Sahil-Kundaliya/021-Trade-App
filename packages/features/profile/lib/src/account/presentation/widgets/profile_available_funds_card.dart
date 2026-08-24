import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ProfileAvailableFundsCard extends StatelessWidget {
  const ProfileAvailableFundsCard({
    required this.balance,
    this.onTap,
    super.key,
  });

  final double balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.appColors.primaryContainer,
              borderRadius: AppRadius.mdBorderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: context.appColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Funds',
                  style: context.appTextStyles.label.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SensitiveValueText(
                  FinancialFormatter.price(balance),
                  type: SensitiveValueType.currency,
                  style: context.appTextStyles.financialLarge.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.md),
            Icon(Icons.chevron_right, color: context.appColors.textTertiary),
          ],
        ],
      ),
    );
  }
}
