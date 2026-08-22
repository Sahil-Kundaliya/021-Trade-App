import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class FundQuickTradeActions extends StatelessWidget {
  const FundQuickTradeActions({
    required this.onBuy,
    required this.onSell,
    super.key,
  });

  final VoidCallback onBuy;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Trade',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onBuy,
                style: FilledButton.styleFrom(
                  backgroundColor: context.appColors.buy,
                  foregroundColor: context.appColors.textInverse,
                ),
                child: const Text('Buy'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: onSell,
                style: FilledButton.styleFrom(
                  backgroundColor: context.appColors.sell,
                  foregroundColor: context.appColors.textInverse,
                ),
                child: const Text('Sell'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
