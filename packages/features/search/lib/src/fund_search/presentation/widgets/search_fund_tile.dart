import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/searchable_fund.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';

class SearchFundTile extends StatelessWidget {
  const SearchFundTile({required this.fund, this.onTap, super.key});

  final SearchableFund fund;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '${fund.symbol}, ${fund.exchange.code}, ${fund.category.label}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      fund.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${fund.exchange.code} • ${fund.category.label}',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _SearchLiveQuote(fund: fund),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchLiveQuote extends StatelessWidget {
  const _SearchLiveQuote({required this.fund});

  final SearchableFund fund;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, MarketQuoteViewData>(
      selector: (state) {
        final tick = state.livePrices[fund.marketKey];
        return MarketQuoteViewData(
          ltp: tick?.ltp ?? fund.ltp,
          change: tick?.change ?? fund.change,
          changePercent: tick?.changePercent ?? fund.changePercent,
          liveDirection: _liveDirection(tick),
          liveUpdateId: tick?.sequence,
        );
      },
      builder: (context, quote) => MarketQuote(
        ltp: quote.ltp,
        change: quote.change,
        changePercent: quote.changePercent,
        liveDirection: quote.liveDirection,
        liveUpdateId: quote.liveUpdateId,
      ),
    );
  }
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };
