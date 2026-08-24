import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist_fund.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_state.dart';

class WatchlistStockTile extends StatelessWidget {
  const WatchlistStockTile({
    required this.stock,
    this.onTap,
    this.reorderIndex,
    this.enableLiveQuote = true,
    super.key,
  });

  final WatchlistFund stock;
  final VoidCallback? onTap;
  final int? reorderIndex;
  final bool enableLiveQuote;

  @override
  Widget build(BuildContext context) {
    return _TileBody(
      stock: stock,
      onTap: onTap,
      reorderIndex: reorderIndex,
      enableLiveQuote: enableLiveQuote,
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.stock,
    this.onTap,
    this.reorderIndex,
    this.enableLiveQuote = true,
  });

  final WatchlistFund stock;
  final VoidCallback? onTap;
  final int? reorderIndex;
  final bool enableLiveQuote;

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
              if (reorderIndex != null) ...[
                _FundDragHandle(index: reorderIndex!, symbol: stock.symbol),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
              enableLiveQuote
                  ? _WatchlistLiveQuote(stock: stock)
                  : MarketQuote(
                      ltp: stock.ltp,
                      change: stock.change,
                      changePercent: stock.changePercent,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FundDragHandle extends StatelessWidget {
  const _FundDragHandle({required this.index, required this.symbol});

  final int index;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: Semantics(
        label: 'Reorder $symbol',
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Icon(
              Icons.drag_indicator,
              size: AppSizes.iconSm,
              color: context.appColors.textTertiary,
            ),
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
