import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class AddFundsConfirmation extends StatelessWidget {
  const AddFundsConfirmation({
    required this.addedAmount,
    required this.availableBalance,
    required this.onDone,
    super.key,
  });

  final double addedAmount;
  final double availableBalance;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: context.motionDuration(AppMotion.standard),
                curve: AppMotionCurves.emphasized,
                tween: Tween(begin: 0.92, end: 1),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Icon(
                  Icons.check_circle,
                  size: AppSizes.iconLg,
                  color: context.appColors.positive,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Funds Added', style: context.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your trading balance has been updated.',
                textAlign: TextAlign.center,
                style: context.appTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  children: [
                    _AmountRow(label: 'Amount Added', value: addedAmount),
                    const AppDivider(),
                    _AmountRow(
                      label: 'Available Funds',
                      value: availableBalance,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Done', onPressed: onDone, expand: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: context.appTextStyles.bodySecondary),
        ),
        SensitiveValueText(
          FinancialFormatter.price(value),
          type: SensitiveValueType.currency,
          style: context.appTextStyles.tableValue,
        ),
      ],
    ),
  );
}
