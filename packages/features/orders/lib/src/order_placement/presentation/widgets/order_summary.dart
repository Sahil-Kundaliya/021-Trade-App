import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../bloc/order_placement_state.dart';
import '../../domain/enums/order_enums.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({required this.state, super.key});
  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) {
    final instrument = state.instrument!;
    final rows = <(String, String)>[
      ('Side', _title(state.side.name)),
      ('Exchange', state.exchange!.name.toUpperCase()),
      ('Product', _title(state.product.name)),
      ('Order Type', _orderType(state.orderType.name)),
      if (instrument.isDerivative)
        ('Lots', '${state.quantity ~/ instrument.lotSize}'),
      ('Quantity', '${state.quantity}'),
      if (state.showsLimitPrice) ('Limit Price', _money(state.limitPrice ?? 0)),
      if (state.showsTriggerPrice)
        ('Trigger Price', _money(state.triggerPrice ?? 0)),
      ('LTP', _money(instrument.ltp)),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORDER SUMMARY', style: context.appTextStyles.tableHeader),
          const SizedBox(height: AppSpacing.md),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(row.$2, style: context.appTextStyles.tableValue),
                ],
              ),
            ),
          ),
          const AppDivider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  state.orderType.usesEstimatedMarketPrice
                      ? 'Estimated Value'
                      : 'Order Value',
                ),
              ),
              Text(
                _money(state.estimatedOrderValue),
                style: context.appTextStyles.orderValue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _money(double value) => '₹${value.toStringAsFixed(2)}';
  static String _title(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
  static String _orderType(String value) => switch (value) {
    'stopLoss' => 'SL',
    'stopLossMarket' => 'SL-M',
    _ => _title(value),
  };
}
