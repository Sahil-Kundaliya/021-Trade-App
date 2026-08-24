import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/watchlist_fund.dart';
import 'watchlist_stock_tile.dart';

class WatchlistStockList extends StatelessWidget {
  const WatchlistStockList({
    required this.stocks,
    this.onStockTap,
    this.onReorder,
    super.key,
  });

  final List<WatchlistFund> stocks;
  final ValueChanged<WatchlistFund>? onStockTap;
  final ReorderCallback? onReorder;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const AppEmptyState(
        title: 'No fund added',
        description: 'Add stocks to start tracking the market.',
        icon: Icons.bookmark_border,
      );
    }

    if (onReorder != null) {
      return ReorderableListView.builder(
        padding: EdgeInsets.zero,
        buildDefaultDragHandles: false,
        itemCount: stocks.length,
        onReorderItem: onReorder,
        proxyDecorator: (_, index, animation) => _WatchlistFundReorderProxy(
          stock: stocks[index],
          index: index,
          animation: animation,
        ),
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(stock.marketKey),
            index: index,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WatchlistStockTile(
                  stock: stock,
                  reorderIndex: index,
                  onTap: onStockTap == null ? null : () => onStockTap!(stock),
                ),
                if (index != stocks.length - 1) const AppDivider(),
              ],
            ),
          );
        },
      );
    }

    return ListView.separated(
      itemCount: stocks.length,
      separatorBuilder: (_, _) => const AppDivider(),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return WatchlistStockTile(
          key: ValueKey(stock.marketKey),
          stock: stock,
          onTap: onStockTap == null ? null : () => onStockTap!(stock),
        );
      },
    );
  }
}

class _WatchlistFundReorderProxy extends StatelessWidget {
  const _WatchlistFundReorderProxy({
    required this.stock,
    required this.index,
    required this.animation,
  });

  final WatchlistFund stock;
  final int index;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final highlight = Color.lerp(
          context.appColors.selection.withValues(alpha: 0.45),
          context.appColors.selection,
          animation.value,
        )!;
        return Align(
          alignment: Alignment.topCenter,
          widthFactor: 1,
          heightFactor: 1,
          child: Material(
            type: MaterialType.transparency,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.mdBorderRadius,
                border: Border.all(color: highlight, width: AppBorders.strong),
              ),
              child: child,
            ),
          ),
        );
      },
      child: IgnorePointer(
        child: WatchlistStockTile(
          stock: stock,
          reorderIndex: index,
          enableLiveQuote: false,
        ),
      ),
    );
  }
}
