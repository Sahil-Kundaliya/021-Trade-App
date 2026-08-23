import 'package:core_ui/core_ui.dart';
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
    return BlocSelector<OrderPlacementBloc, OrderPlacementState, MarketQuoteViewData?>(
      selector: (state) {
        final instrument = state.instrument;
        if (instrument == null) return null;
        return MarketQuoteViewData(
          ltp: instrument.ltp,
          change: instrument.change,
          changePercent: instrument.changePercent,
        );
      },
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();
        return MarketQuote(
          ltp: quote.ltp,
          change: quote.change,
          changePercent: quote.changePercent,
          priceStyle: context.appTextStyles.priceMedium,
          changeStyle: context.appTextStyles.percentageMedium,
        );
      },
    );
  }
}
