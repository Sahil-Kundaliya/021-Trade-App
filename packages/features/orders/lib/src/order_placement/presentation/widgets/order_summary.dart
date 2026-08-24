import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart'
    show LivePriceDirection, LivePriceTick;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/order_placement_bloc.dart';
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
      if (state.showsLimitPrice)
        ('Limit Price', FinancialFormatter.price(state.limitPrice ?? 0)),
      if (state.showsTriggerPrice)
        ('Trigger Price', FinancialFormatter.price(state.triggerPrice ?? 0)),
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
                  if (_sensitiveLabels.contains(row.$1))
                    SensitiveValueText(
                      row.$2,
                      type: row.$1.contains('Price') || row.$1 == 'LTP'
                          ? SensitiveValueType.currency
                          : SensitiveValueType.quantity,
                      style: context.appTextStyles.tableValue,
                    )
                  else
                    Text(row.$2, style: context.appTextStyles.tableValue),
                ],
              ),
            ),
          ),
          _LiveSummaryRow(label: 'LTP'),
          const AppDivider(),
          const SizedBox(height: AppSpacing.sm),
          BlocSelector<OrderPlacementBloc, OrderPlacementState, (bool, double)>(
            selector: (value) => (
              value.orderType.usesEstimatedMarketPrice,
              value.estimatedOrderValue,
            ),
            builder: (context, data) => Row(
              children: [
                Expanded(
                  child: Text(data.$1 ? 'Estimated Value' : 'Order Value'),
                ),
                SensitiveValueText(
                  FinancialFormatter.price(data.$2),
                  type: SensitiveValueType.currency,
                  style: context.appTextStyles.orderValue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _title(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
  static String _orderType(String value) => switch (value) {
    'stopLoss' => 'SL',
    'stopLossMarket' => 'SL-M',
    _ => _title(value),
  };
}

class _LiveSummaryRow extends StatelessWidget {
  const _LiveSummaryRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        BlocSelector<
          OrderPlacementBloc,
          OrderPlacementState,
          MarketQuoteViewData
        >(
          selector: (state) {
            final tick = state.liveTick;
            return MarketQuoteViewData(
              ltp: state.instrument?.ltp ?? 0,
              change: 0,
              changePercent: 0,
              liveDirection: _liveDirection(tick),
              liveUpdateId: tick?.sequence,
            );
          },
          builder: (context, quote) => LiveValueFlash(
            direction: quote.liveDirection,
            updateId: quote.liveUpdateId,
            normalColor:
                context.appTextStyles.tableValue.color ??
                DefaultTextStyle.of(context).style.color ??
                context.appColors.textPrimary,
            builder: (color) => SensitiveValueText(
              FinancialFormatter.price(quote.ltp),
              type: SensitiveValueType.currency,
              style: context.appTextStyles.tableValue.copyWith(color: color),
            ),
          ),
        ),
      ],
    ),
  );
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };

const _sensitiveLabels = <String>{
  'Lots',
  'Quantity',
  'Limit Price',
  'Trigger Price',
  'LTP',
};
