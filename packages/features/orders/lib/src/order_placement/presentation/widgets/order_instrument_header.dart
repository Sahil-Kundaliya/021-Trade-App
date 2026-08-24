import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/order_placement_bloc.dart';
import '../bloc/order_placement_state.dart';

class OrderInstrumentHeader extends StatelessWidget {
  const OrderInstrumentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderPlacementBloc, OrderPlacementState>(
      buildWhen: (previous, current) =>
          previous.instrument?.id != current.instrument?.id ||
          previous.instrument?.symbol != current.instrument?.symbol ||
          previous.instrument?.companyName != current.instrument?.companyName,
      builder: (context, state) {
        final instrument = state.instrument;
        if (instrument == null) {
          return Text('Order', style: context.textTheme.titleLarge);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instrument.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    instrument.companyName,
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
            const _HeaderQuote(),
          ],
        );
      },
    );
  }
}

class _HeaderQuote extends StatelessWidget {
  const _HeaderQuote();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      OrderPlacementBloc,
      OrderPlacementState,
      MarketQuoteViewData?
    >(
      selector: (state) {
        final instrument = state.instrument;
        if (instrument == null) return null;
        return MarketQuoteViewData(
          ltp: instrument.ltp,
          change: instrument.change,
          changePercent: instrument.changePercent,
          liveDirection: _liveDirection(state.liveTick),
          liveUpdateId: state.liveTick?.sequence,
        );
      },
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();
        return MarketQuote(
          ltp: quote.ltp,
          change: quote.change,
          changePercent: quote.changePercent,
          liveDirection: quote.liveDirection,
          liveUpdateId: quote.liveUpdateId,
          priceStyle: context.appTextStyles.priceMedium,
          changeStyle: context.appTextStyles.percentageMedium,
        );
      },
    );
  }
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };
