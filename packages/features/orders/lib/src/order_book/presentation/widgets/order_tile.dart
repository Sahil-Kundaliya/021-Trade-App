import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import '../formatters/order_format.dart';
import 'order_metadata_chip.dart';
import 'order_status_badge.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, required this.onTap, super.key});

  final TradeOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return _WideOrderTile(order: order);
          }
          return _CompactOrderTile(order: order);
        },
      ),
    );
  }
}

class _CompactOrderTile extends StatelessWidget {
  const _CompactOrderTile({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SideLabel(order: order),
            const Spacer(),
            Flexible(child: OrderStatusBadge(status: order.status)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _OrderIdentity(order: order)),
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: _Metadata(order: order)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Metric(
                label: 'Qty',
                value: '${order.filledQuantity} / ${order.quantity}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PrimaryPrice(
                order: order,
                crossAxisAlignment: CrossAxisAlignment.end,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _OrderTypeAndSecondaryPrice(order: order)),
            const SizedBox(width: AppSpacing.md),
            Text(
              OrderFormat.time(order.orderTime),
              style: context.appTextStyles.tableValue.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideOrderTile extends StatelessWidget {
  const _WideOrderTile({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 56, child: _SideLabel(order: order)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(flex: 3, child: _OrderIdentity(order: order)),
        Expanded(flex: 2, child: _Metadata(order: order)),
        Expanded(
          child: _Metric(
            label: 'Qty',
            value: '${order.filledQuantity} / ${order.quantity}',
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
        Expanded(flex: 2, child: _PrimaryPrice(order: order)),
        Expanded(flex: 2, child: OrderStatusBadge(status: order.status)),
        const SizedBox(width: AppSpacing.md),
        Text(
          OrderFormat.time(order.orderTime),
          style: context.appTextStyles.tableValue.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    return Text(
      OrderFormat.side(order.side),
      style: context.textTheme.labelLarge?.copyWith(
        color: isBuy ? context.appColors.buy : context.appColors.sell,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _OrderIdentity extends StatelessWidget {
  const _OrderIdentity({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.symbol,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
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
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        OrderMetadataChip(label: OrderFormat.exchange(order.exchange)),
        OrderMetadataChip(label: order.instrumentType),
      ],
    );
  }
}

class _PrimaryPrice extends StatelessWidget {
  const _PrimaryPrice({
    required this.order,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  });

  final TradeOrder order;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

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
      crossAxisAlignment: crossAxisAlignment,
      textAlign: textAlign,
      emphasize: true,
    );
  }
}

class _OrderTypeAndSecondaryPrice extends StatelessWidget {
  const _OrderTypeAndSecondaryPrice({required this.order});

  final TradeOrder order;

  @override
  Widget build(BuildContext context) {
    final secondary = _secondaryPrice(order);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${OrderFormat.orderType(order.orderType)} · ${OrderFormat.product(order.productType)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        if (secondary != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTextStyles.tableValue.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

String? _secondaryPrice(TradeOrder order) {
  if (order.orderType == TradeOrderType.stopLoss &&
      order.triggerPrice != null &&
      order.limitPrice != null) {
    return 'Trigger ${OrderFormat.currency(order.triggerPrice!)}';
  }
  if ((order.status == OrderStatus.open ||
          order.status == OrderStatus.triggerPending) &&
      order.ltp > 0) {
    return 'LTP ${OrderFormat.currency(order.ltp)}';
  }
  if (order.orderValue != null) {
    return 'Value ${OrderFormat.currency(order.orderValue!)}';
  }
  return null;
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: context.appTextStyles.tableHeader.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          textAlign: textAlign,
          style:
              (emphasize
                      ? context.appTextStyles.orderValue
                      : context.appTextStyles.tableValue)
                  .copyWith(color: context.appColors.textPrimary),
        ),
      ],
    );
  }
}
