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
        itemCount: stocks.length,
        onReorderItem: onReorder!,
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          builder: (context, _) => Material(
            elevation: animation.value * 2,
            borderRadius: AppRadius.mdBorderRadius,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
        itemBuilder: (context, index) => Column(
          key: ValueKey(stocks[index].marketKey),
          children: [
            WatchlistStockTile(
              stock: stocks[index],
              onTap: onStockTap == null
                  ? null
                  : () => onStockTap!(stocks[index]),
            ),
            if (index != stocks.length - 1) const AppDivider(),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: stocks.length,
      separatorBuilder: (_, _) => const AppDivider(),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return WatchlistStockTile(
          stock: stock,
          onTap: onStockTap == null ? null : () => onStockTap!(stock),
        );
      },
    );
  }
}
