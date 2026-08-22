import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class FundActionButtons extends StatelessWidget {
  const FundActionButtons({
    required this.onAddFunds,
    required this.onWithdraw,
    super.key,
  });

  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final addFunds = AppButton(
          label: 'Add Funds',
          leadingIcon: const Icon(Icons.add, size: AppSizes.iconSm),
          onPressed: onAddFunds,
          expand: true,
        );
        final withdraw = SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onWithdraw,
            icon: const Icon(Icons.arrow_outward, size: AppSizes.iconSm),
            label: const Text('Withdraw'),
          ),
        );

        if (constraints.maxWidth < 320) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              addFunds,
              const SizedBox(height: AppSpacing.sm),
              withdraw,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: addFunds),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: withdraw),
          ],
        );
      },
    );
  }
}
