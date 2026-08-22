import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/watchlist_stock.dart';
import 'watchlist_stock_tile.dart';

class WatchlistStockList extends StatelessWidget {
  const WatchlistStockList({required this.stocks, super.key});

  final List<WatchlistStock> stocks;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const AppEmptyState(
        title: 'No stocks in this watchlist',
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
        return WatchlistStockTile(stock: stocks[index]);
      },
    );
  }
}
