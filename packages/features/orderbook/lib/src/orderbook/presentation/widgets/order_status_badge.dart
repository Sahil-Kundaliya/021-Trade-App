import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import '../formatters/order_format.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.pillBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          OrderFormat.status(status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTextStyles.statusLabel.copyWith(
            color: colors.foreground,
          ),
        ),
      ),
    );
  }

  ({Color foreground, Color background}) _colors(BuildContext context) {
    final colors = context.appColors;
    return switch (status) {
      OrderStatus.executed => (
        foreground: colors.positive,
        background: colors.positiveContainer,
      ),
      OrderStatus.open || OrderStatus.pending => (
        foreground: colors.info,
        background: colors.infoContainer,
      ),
      OrderStatus.triggerPending || OrderStatus.partiallyFilled => (
        foreground: colors.warning,
        background: colors.warningContainer,
      ),
      OrderStatus.cancelled => (
        foreground: colors.textSecondary,
        background: colors.surfaceContainer,
      ),
      OrderStatus.rejected => (
        foreground: colors.negative,
        background: colors.negativeContainer,
      ),
    };
  }
}
