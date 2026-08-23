import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist_fund.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_state.dart';

class WatchlistStockTile extends StatelessWidget {
  const WatchlistStockTile({required this.stock, this.onTap, super.key});

  final WatchlistFund stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TileBody(stock: stock, onTap: onTap);
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({required this.stock, this.onTap});

  final WatchlistFund stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
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
                      stock.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTextStyles.marketSymbol.copyWith(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stock.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xxs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        for (final tag in stock.tags) _StockTag(label: tag),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _WatchlistLiveQuote(stock: stock),
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchlistLiveQuote extends StatelessWidget {
  const _WatchlistLiveQuote({required this.stock});

  final WatchlistFund stock;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WatchlistBloc, WatchlistState, MarketQuoteViewData>(
      selector: (state) {
        final tick = state.livePrices[stock.marketKey];
        return MarketQuoteViewData(
          ltp: tick?.ltp ?? stock.ltp,
          change: tick?.change ?? stock.change,
          changePercent: tick?.changePercent ?? stock.changePercent,
        );
      },
      builder: (context, quote) => MarketQuote(
        ltp: quote.ltp,
        change: quote.change,
        changePercent: quote.changePercent,
      ),
    );
  }
}

class _StockTag extends StatelessWidget {
  const _StockTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: AppRadius.xsBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: context.appTextStyles.caption.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
