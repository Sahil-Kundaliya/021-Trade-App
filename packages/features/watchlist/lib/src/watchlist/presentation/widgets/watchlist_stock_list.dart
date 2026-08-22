import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/watchlist_fund.dart';
import 'watchlist_stock_tile.dart';

class WatchlistStockList extends StatelessWidget {
  const WatchlistStockList({required this.stocks, this.onStockTap, super.key});

  final List<WatchlistFund> stocks;
  final ValueChanged<WatchlistFund>? onStockTap;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const AppEmptyState(
        title: 'No fund added',
        description: 'Add stocks to start tracking the market.',
        icon: Icons.bookmark_border,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
