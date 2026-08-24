import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class AvailableFundsSummary extends StatelessWidget {
  const AvailableFundsSummary({required this.balance, super.key});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
