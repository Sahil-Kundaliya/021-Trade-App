import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';

import '../../domain/entities/watchlist.dart';
import '../../domain/entities/watchlist_fund.dart';
import 'watchlist_stock_list.dart';
import 'watchlist_tabs.dart';

class WatchlistSection extends StatelessWidget {
  const WatchlistSection({
    required this.watchlists,
    required this.selectedWatchlistId,
    required this.funds,
    this.onSelected,
    this.onStockTap,
    super.key,
  });

  final List<Watchlist> watchlists;
  final String? selectedWatchlistId;
  final List<WatchlistFund> funds;
  final ValueChanged<String>? onSelected;
  final ValueChanged<WatchlistFund>? onStockTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (watchlists.isNotEmpty)
          WatchlistTabs(
            labels: watchlists.map((item) => item.name).toList(growable: false),
            selectedIndex: watchlists.indexWhere(
              (item) => item.id == selectedWatchlistId,
            ),
            onSelected: (index) => onSelected?.call(watchlists[index].id),
          ),
        const SizedBox(height: AppSpacing.sm),
        WatchlistStockList(stocks: funds, onStockTap: onStockTap),
      ],
    );
  }
}
