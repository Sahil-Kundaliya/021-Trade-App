import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/fund_activity.dart';
import '../formatters/fund_currency_format.dart';

class FundActivityTile extends StatelessWidget {
  const FundActivityTile({required this.activity, super.key});

  final FundActivity activity;

  @override
  Widget build(BuildContext context) {
    final isDeposit = activity.type == FundActivityType.deposit;
    final iconColor = isDeposit
        ? context.appColors.positive
        : context.appColors.textSecondary;
    final iconBackground = isDeposit
        ? context.appColors.positiveContainer
        : context.appColors.surfaceContainer;
    final amountColor = isDeposit
        ? context.appColors.positive
        : context.appColors.textPrimary;

    return Semantics(
      label:
          '${activity.title}, ${FundCurrencyFormat.signedCurrency(activity.amount, isCredit: isDeposit)}, ${activity.method}, ${activity.dateLabel}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: AppRadius.mdBorderRadius,
              ),
              child: SizedBox.square(
                dimension: AppSizes.touchTarget,
                child: Icon(
                  isDeposit ? Icons.south_west : Icons.north_east,
                  size: AppSizes.iconSm,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${activity.method} · ${activity.dateLabel}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              FundCurrencyFormat.signedCurrency(
                activity.amount,
                isCredit: isDeposit,
              ),
              maxLines: 1,
              style: context.appTextStyles.orderValue.copyWith(
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
