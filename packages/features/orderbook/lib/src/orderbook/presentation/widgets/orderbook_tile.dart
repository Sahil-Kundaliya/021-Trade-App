import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import '../formatters/order_format.dart';
import 'order_status_badge.dart';

class OrderBookTile extends StatelessWidget {
  const OrderBookTile({required this.order, required this.onTap, super.key});

  final TradeOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 700
          ? _WideTile(order: order)
          : _CompactTile(order: order),
    ),
  );
}

class _CompactTile extends StatelessWidget {
  const _CompactTile({required this.order});
  final TradeOrder order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _Side(order: order),
          const Spacer(),
          OrderStatusBadge(status: order.status),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Identity(order: order)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: _Metadata(order: order)),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Qty',
              value: '${order.filledQuantity} / ${order.quantity}',
              sensitiveType: SensitiveValueType.quantity,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _Price(order: order, alignEnd: true)),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              '${OrderFormat.orderType(order.orderType)} · ${OrderFormat.product(order.productType)}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Text(
            OrderFormat.time(order.createdAt),
            style: context.appTextStyles.tableValue.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    ],
  );
}

class _WideTile extends StatelessWidget {
  const _WideTile({required this.order});
  final TradeOrder order;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 56, child: _Side(order: order)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(flex: 3, child: _Identity(order: order)),
      Expanded(flex: 2, child: _Metadata(order: order)),
      Expanded(
        child: _Metric(
          label: 'Qty',
          value: '${order.filledQuantity} / ${order.quantity}',
          sensitiveType: SensitiveValueType.quantity,
        ),
      ),
      Expanded(
        flex: 2,
        child: _Metric(
          label: 'Type',
          value:
              '${OrderFormat.orderType(order.orderType)} · ${OrderFormat.product(order.productType)}',
        ),
      ),
      Expanded(flex: 2, child: _Price(order: order)),
      Expanded(flex: 2, child: OrderStatusBadge(status: order.status)),
      const SizedBox(width: AppSpacing.md),
      Text(
        OrderFormat.time(order.createdAt),
        style: context.appTextStyles.tableValue,
      ),
    ],
  );
}

class _Side extends StatelessWidget {
  const _Side({required this.order});
  final TradeOrder order;

  @override
  Widget build(BuildContext context) => Text(
    OrderFormat.side(order.side),
    style: context.textTheme.labelLarge?.copyWith(
      color: order.side == OrderSide.buy
          ? context.appColors.buy
          : context.appColors.sell,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Identity extends StatelessWidget {
  const _Identity({required this.order});
  final TradeOrder order;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        order.symbol,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleSmall?.copyWith(
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
  );
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.order});
  final TradeOrder order;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    children: [
      _Chip(label: OrderFormat.exchange(order.exchange)),
      _Chip(label: order.instrumentType),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.surfaceContainer,
      borderRadius: AppRadius.xsBorderRadius,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    ),
  );
}

class _Price extends StatelessWidget {
  const _Price({required this.order, this.alignEnd = false});
  final TradeOrder order;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final value = order.averagePrice ?? order.limitPrice ?? order.triggerPrice;
    final label = order.averagePrice != null
        ? 'Avg. Price'
        : order.limitPrice != null
        ? 'Limit Price'
        : order.triggerPrice != null
        ? 'Trigger Price'
        : 'Market Price';
    return _Metric(
      label: label,
      value: value == null ? 'At market' : OrderFormat.currency(value),
      alignEnd: alignEnd,
      emphasize: true,
      sensitiveType: value == null ? null : SensitiveValueType.currency,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.emphasize = false,
    this.sensitiveType,
  });
  final String label;
  final String value;
  final bool alignEnd;
  final bool emphasize;
  final SensitiveValueType? sensitiveType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.appTextStyles.tableHeader.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      if (sensitiveType == null)
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: emphasize
              ? context.appTextStyles.orderValue
              : context.appTextStyles.tableValue,
        )
      else
        SensitiveValueText(
          value,
          type: sensitiveType!,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: emphasize
              ? context.appTextStyles.orderValue
              : context.appTextStyles.tableValue,
        ),
    ],
  );
}
