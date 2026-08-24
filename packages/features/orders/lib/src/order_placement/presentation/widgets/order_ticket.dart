import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart'
    show LivePriceDirection, LivePriceTick;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/order_enums.dart';
import '../bloc/order_placement_bloc.dart';
import '../bloc/order_placement_event.dart';
import '../bloc/order_placement_state.dart';
import 'buy_sell_switch.dart';
import 'order_choice_selector.dart';
import 'order_summary.dart';
import 'price_input.dart';
import 'quantity_stepper.dart';

class OrderTicket extends StatelessWidget {
  const OrderTicket({required this.state, super.key});
  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OrderPlacementBloc>();
    final instrument = state.instrument!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.huge,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TicketSection(
                title: 'TRADE',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BuySellSwitch(
                      value: state.side,
                      onChanged: (value) => bloc.add(OrderSideChanged(value)),
                    ),
                    if (state.side == OrderSide.sell) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AvailableQuantity(
                        quantity: state.availableSellQuantity,
                        lotSize: instrument.lotSize,
                        isDerivative: instrument.isDerivative,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    OrderChoiceSelector<TradeExchange>(
                      label: 'Exchange',
                      values: instrument.availableExchanges,
                      selected: state.exchange!,
                      labelOf: (value) => value.name.toUpperCase(),
                      onChanged: (value) =>
                          bloc.add(OrderExchangeChanged(value)),
                      errorText: state.errorFor('exchange'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TicketSection(
                title: 'QUANTITY & PRODUCT',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuantityStepper(
                      quantity: state.quantity,
                      lotSize: instrument.lotSize,
                      isDerivative: instrument.isDerivative,
                      onIncrement: () =>
                          bloc.add(const OrderQuantityIncremented()),
                      onDecrement: () =>
                          bloc.add(const OrderQuantityDecremented()),
                      onChanged: (value) =>
                          bloc.add(OrderQuantityChanged(value)),
                      errorText: state.errorFor('quantity'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OrderChoiceSelector<TradeProduct>(
                      label: 'Product',
                      values: instrument.allowedProducts,
                      selected: state.product,
                      labelOf: _productLabel,
                      onChanged: (value) =>
                          bloc.add(OrderProductChanged(value)),
                      errorText: state.errorFor('product'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TicketSection(
                title: 'ORDER DETAILS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OrderChoiceSelector<TradeOrderType>(
                      label: 'Order Type',
                      values: instrument.allowedOrderTypes,
                      selected: state.orderType,
                      labelOf: _orderTypeLabel,
                      onChanged: (value) => bloc.add(OrderTypeChanged(value)),
                      errorText: state.errorFor('orderType'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.orderType == TradeOrderType.market) ...[
                      const _MarketPrice(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (state.showsTriggerPrice) ...[
                      PriceInput(
                        label: 'Trigger Price',
                        value: state.triggerPrice,
                        onChanged: (value) =>
                            bloc.add(OrderTriggerPriceChanged(value)),
                        errorText: state.errorFor('triggerPrice'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (state.showsLimitPrice) ...[
                      PriceInput(
                        label: 'Limit Price',
                        value: state.limitPrice,
                        onChanged: (value) =>
                            bloc.add(OrderLimitPriceChanged(value)),
                        errorText: state.errorFor('limitPrice'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      expandedAlignment: Alignment.centerLeft,
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      childrenPadding: const EdgeInsets.only(
                        bottom: AppSpacing.md,
                      ),
                      title: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('More Options', textAlign: TextAlign.left),
                      ),
                      children: [
                        OrderChoiceSelector<OrderValidity>(
                          label: 'Validity',
                          values: OrderValidity.values,
                          selected: state.validity,
                          labelOf: (value) => value.name.toUpperCase(),
                          onChanged: (value) =>
                              bloc.add(OrderValidityChanged(value)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OrderSummary(state: state),
              if (state.errorFor('form') != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    state.errorFor('form')!,
                    style: context.appTextStyles.bodySecondary.copyWith(
                      color: context.appColors.negative,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _productLabel(TradeProduct value) => switch (value) {
    TradeProduct.delivery => 'Delivery',
    TradeProduct.intraday => 'Intraday',
    TradeProduct.overnight => 'Overnight',
  };
  static String _orderTypeLabel(TradeOrderType value) => switch (value) {
    TradeOrderType.market => 'Market',
    TradeOrderType.limit => 'Limit',
    TradeOrderType.stopLoss => 'SL',
    TradeOrderType.stopLossMarket => 'SL-M',
  };
}

class _TicketSection extends StatelessWidget {
  const _TicketSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    ),
  );
}

class _MarketPrice extends StatelessWidget {
  const _MarketPrice();

  @override
  Widget build(
    BuildContext context,
  ) => BlocSelector<OrderPlacementBloc, OrderPlacementState, MarketQuoteViewData>(
    selector: (state) {
      final instrument = state.instrument;
      final tick = state.liveTick;
      return MarketQuoteViewData(
        ltp: instrument?.ltp ?? 0,
        change: instrument?.change ?? 0,
        changePercent: instrument?.changePercent ?? 0,
        liveDirection: _liveDirection(tick),
        liveUpdateId: tick?.sequence,
      );
    },
    builder: (context, quote) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.infoContainer,
        borderRadius: AppRadius.mdBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price · Market Price', style: context.textTheme.labelLarge),
          LiveValueFlash(
            direction: quote.liveDirection,
            updateId: quote.liveUpdateId,
            normalColor:
                DefaultTextStyle.of(context).style.color ??
                context.appColors.textPrimary,
            builder: (color) => SensitiveValueText(
              'Current LTP ${FinancialFormatter.price(quote.ltp)}',
              maskedValue: 'Current LTP ${PrivacyMask.currency}',
              style: TextStyle(color: color),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Market orders execute at the best available price. Actual execution may vary from the displayed LTP.',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };

class _AvailableQuantity extends StatelessWidget {
  const _AvailableQuantity({
    required this.quantity,
    required this.lotSize,
    required this.isDerivative,
  });

  final int quantity;
  final int lotSize;
  final bool isDerivative;

  @override
  Widget build(BuildContext context) {
    final lots = lotSize <= 0 ? 0 : quantity ~/ lotSize;
    final value = isDerivative
        ? '$lots ${lots == 1 ? 'Lot' : 'Lots'} · $quantity Qty'
        : '$quantity Qty';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Available to sell',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        SensitiveValueText(
          value,
          type: SensitiveValueType.quantity,
          style: context.textTheme.labelMedium,
        ),
      ],
    );
  }
}
