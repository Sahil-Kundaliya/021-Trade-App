import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/placed_order.dart';
import '../../domain/enums/order_enums.dart';

class OrderConfirmation extends StatelessWidget {
  const OrderConfirmation({
    required this.order,
    required this.onViewOrderBook,
    required this.onDone,
    super.key,
  });
  final PlacedOrder order;
  final VoidCallback onViewOrderBook;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final draft = order.draft;
    final status = switch (order.status) {
      PlacedOrderStatus.executed => 'EXECUTED',
      PlacedOrderStatus.open => 'OPEN',
      PlacedOrderStatus.triggerPending => 'TRIGGER PENDING',
    };
    final sideColor = draft.side == OrderSide.buy
        ? context.appColors.buy
        : context.appColors.sell;
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
              Text('Order Placed', style: context.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${draft.side.name.toUpperCase()} · $status',
                style: context.textTheme.titleMedium?.copyWith(
                  color: sideColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  children: [
                    Text(
                      draft.instrument.symbol,
                      style: context.textTheme.titleLarge,
                    ),
                    Text(
                      '${draft.exchange.name.toUpperCase()} · ${draft.instrument.instrumentType.name}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _row(
                      context,
                      'Quantity',
                      '${draft.quantity} Qty',
                      type: SensitiveValueType.quantity,
                    ),
                    if (order.averagePrice != null)
                      _row(
                        context,
                        'Executed Price',
                        _money(order.averagePrice!),
                        type: SensitiveValueType.currency,
                      ),
                    if (draft.limitPrice != null)
                      _row(
                        context,
                        'Limit Price',
                        _money(draft.limitPrice!),
                        type: SensitiveValueType.currency,
                      ),
                    if (draft.triggerPrice != null)
                      _row(
                        context,
                        'Trigger Price',
                        _money(draft.triggerPrice!),
                        type: SensitiveValueType.currency,
                      ),
                    _row(
                      context,
                      'Order Value',
                      _money(order.orderValue),
                      type: SensitiveValueType.currency,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: onViewOrderBook,
                child: const Text('View Order Book'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Done', onPressed: onDone, expand: true),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _row(
    BuildContext context,
    String label,
    String value, {
    SensitiveValueType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.appTextStyles.bodySecondary.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        type == null ? Text(value) : SensitiveValueText(value, type: type),
      ],
    ),
  );
  static String _money(double value) => '₹${value.toStringAsFixed(2)}';
}
