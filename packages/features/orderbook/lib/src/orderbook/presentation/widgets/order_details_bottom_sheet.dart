import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import '../formatters/order_format.dart';
import 'order_status_badge.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  const OrderDetailsBottomSheet({required this.order, super.key});
  final TradeOrder order;

  static Future<void> show(BuildContext context, TradeOrder order) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => OrderDetailsBottomSheet(order: order),
      );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.sm,
      AppSpacing.xl,
      AppSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.symbol,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order.companyName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              OrderFormat.side(order.side),
              style: context.textTheme.labelLarge?.copyWith(
                color: order.side == OrderSide.buy
                    ? context.appColors.buy
                    : context.appColors.sell,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Order Details', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _Row(label: 'Order ID', value: order.orderId),
            if (order.exchangeOrderId != null)
              _Row(label: 'Exchange Order ID', value: order.exchangeOrderId!),
            _Row(
              label: 'Exchange',
              value: OrderFormat.exchange(order.exchange),
            ),
            _Row(label: 'Segment', value: order.instrumentType),
            _Row(
              label: 'Product',
              value: OrderFormat.product(order.productType),
            ),
            _Row(
              label: 'Order Type',
              value: OrderFormat.orderType(order.orderType),
            ),
            _Row(label: 'Validity', value: order.validity),
            const AppDivider(),
            _Row(label: 'Quantity', value: '${order.quantity}'),
            _Row(label: 'Filled', value: '${order.filledQuantity}'),
            _Row(label: 'Pending', value: '${order.pendingQuantity}'),
            if (order.averagePrice != null)
              _Row(
                label: 'Average Price',
                value: OrderFormat.currency(order.averagePrice!),
              ),
            if (order.limitPrice != null)
              _Row(
                label: 'Limit Price',
                value: OrderFormat.currency(order.limitPrice!),
              ),
            if (order.triggerPrice != null)
              _Row(
                label: 'Trigger Price',
                value: OrderFormat.currency(order.triggerPrice!),
              ),
            _Row(label: 'LTP', value: OrderFormat.currency(order.ltp)),
            if (order.orderValue != null)
              _Row(
                label: 'Order Value',
                value: OrderFormat.currency(order.orderValue!),
              ),
            const AppDivider(),
            _Row(label: 'Status', value: OrderFormat.status(order.status)),
            _Row(
              label: 'Order Time',
              value: OrderFormat.time(order.createdAt, includeSeconds: true),
            ),
            if (order.rejectionReason != null) ...[
              const SizedBox(height: AppSpacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColors.negativeContainer,
                  borderRadius: AppRadius.smBorderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rejection Reason',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.appColors.negative,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(order.rejectionReason!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.appTextStyles.tableValue,
          ),
        ),
      ],
    ),
  );
}
