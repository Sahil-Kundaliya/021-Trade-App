import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/enums/order_enums.dart';
import '../bloc/order_placement_state.dart';
import 'order_summary.dart';

class OrderReview extends StatelessWidget {
  const OrderReview({
    required this.state,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });
  final OrderPlacementState state;
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final buy = state.side == OrderSide.buy;
    final color = buy ? context.appColors.buy : context.appColors.sell;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REVIEW ORDER', style: context.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.lg),
              Text(
                state.side.name.toUpperCase(),
                style: context.textTheme.titleLarge?.copyWith(color: color),
              ),
              Text(
                state.instrument!.symbol,
                style: context.textTheme.headlineSmall,
              ),
              Text(
                '${state.exchange!.name.toUpperCase()} · ${state.instrument!.instrumentType.name}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              OrderSummary(state: state),
              if (!buy) ...[
                const SizedBox(height: AppSpacing.md),
                _SellAvailability(state: state),
              ],
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: context.appColors.negative),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isPlacingOrder ? null : onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: context.appColors.textInverse,
                      ),
                      onPressed: onConfirm,
                      child: state.isPlacingOrder
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Confirm ${buy ? 'Buy' : 'Sell'}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellAvailability extends StatelessWidget {
  const _SellAvailability({required this.state});

  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        _row(context, 'Available quantity', state.availableSellQuantity),
        const SizedBox(height: AppSpacing.sm),
        _row(context, 'Sell quantity', state.quantity),
        const SizedBox(height: AppSpacing.sm),
        _row(
          context,
          'Remaining',
          state.availableSellQuantity - state.quantity,
        ),
      ],
    ),
  );

  Widget _row(BuildContext context, String label, int value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: context.textTheme.bodySmall),
      SensitiveValueText(
        '$value',
        type: SensitiveValueType.quantity,
        style: context.textTheme.labelMedium,
      ),
    ],
  );
}
