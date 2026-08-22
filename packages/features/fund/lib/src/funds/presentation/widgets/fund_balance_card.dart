import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/fund_summary.dart';
import '../formatters/fund_currency_format.dart';
import 'fund_action_buttons.dart';

class FundBalanceCard extends StatelessWidget {
  const FundBalanceCard({
    required this.summary,
    required this.onAddFunds,
    required this.onWithdraw,
    super.key,
  });

  final FundSummary summary;
  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border.all(color: context.appColors.borderSubtle),
        borderRadius: AppRadius.lgBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available to Trade',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              label:
                  'Available to trade ${FundCurrencyFormat.currency(summary.availableToTrade)}',
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  FundCurrencyFormat.currency(summary.availableToTrade),
                  maxLines: 1,
                  style: context.appTextStyles.marketValueLarge.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Withdrawable',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              FundCurrencyFormat.currency(summary.withdrawableBalance),
              style: context.appTextStyles.marketValueMedium.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _WithdrawalInfoNote(),
            const SizedBox(height: AppSpacing.xl),
            FundActionButtons(onAddFunds: onAddFunds, onWithdraw: onWithdraw),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalInfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.infoContainer,
        borderRadius: AppRadius.smBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: AppSizes.iconSm,
              color: context.appColors.info,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Recent credits may be available for trading before they become available for withdrawal.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
