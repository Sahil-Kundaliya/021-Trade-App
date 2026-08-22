import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import '../formatters/order_format.dart';
import 'order_status_badge.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  const OrderDetailsBottomSheet({required this.order, super.key});

  final TradeOrder order;

  static Future<void> show(BuildContext context, TradeOrder order) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => OrderDetailsBottomSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    return SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.symbol,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.appColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          order.companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  color: isBuy ? context.appColors.buy : context.appColors.sell,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Order Details', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(
                label: 'Exchange',
                value: OrderFormat.exchange(order.exchange),
              ),
              _DetailRow(label: 'Segment', value: order.instrumentType),
              _DetailRow(
                label: 'Product',
                value: OrderFormat.product(order.productType),
              ),
              _DetailRow(
                label: 'Order Type',
                value: OrderFormat.orderType(order.orderType),
              ),
              _DetailRow(label: 'Validity', value: order.validity),
              const AppDivider(),
              _DetailRow(label: 'Quantity', value: '${order.quantity}'),
              _DetailRow(label: 'Filled', value: '${order.filledQuantity}'),
              _DetailRow(label: 'Pending', value: '${order.pendingQuantity}'),
              if (order.averagePrice != null)
                _DetailRow(
                  label: 'Average Price',
                  value: OrderFormat.currency(order.averagePrice!),
                ),
              if (order.limitPrice != null)
                _DetailRow(
                  label: 'Limit Price',
                  value: OrderFormat.currency(order.limitPrice!),
                ),
              if (order.triggerPrice != null)
                _DetailRow(
                  label: 'Trigger Price',
                  value: OrderFormat.currency(order.triggerPrice!),
                ),
              _DetailRow(label: 'LTP', value: OrderFormat.currency(order.ltp)),
              if (order.orderValue != null)
                _DetailRow(
                  label: 'Order Value',
                  value: OrderFormat.currency(order.orderValue!),
                ),
              const AppDivider(),
              _DetailRow(
                label: 'Order Time',
                value: OrderFormat.time(order.orderTime, includeSeconds: true),
              ),
              _DetailRow(label: 'Order ID', value: order.orderId),
              if (order.exchangeOrderId != null)
                _DetailRow(
                  label: 'Exchange Order ID',
                  value: order.exchangeOrderId!,
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
                        Text(
                          order.rejectionReason!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                        ),
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              style: context.appTextStyles.tableValue.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
