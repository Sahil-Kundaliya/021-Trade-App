import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';

import '../../data/mock_watchlist_data.dart';
import '../../domain/entities/watchlist_stock.dart';
import 'watchlist_stock_list.dart';
import 'watchlist_tabs.dart';

class WatchlistSection extends StatefulWidget {
  const WatchlistSection({this.onStockTap, super.key});

  final ValueChanged<WatchlistStock>? onStockTap;

  @override
  State<WatchlistSection> createState() => _WatchlistSectionState();
}

class _WatchlistSectionState extends State<WatchlistSection> {
  static const _labels = <String>['Default', 'Watchlist 2', 'Watchlist 3'];

  int selectedWatchlistIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WatchlistTabs(
          labels: _labels,
          selectedIndex: selectedWatchlistIndex,
          onSelected: (index) {
            setState(() => selectedWatchlistIndex = index);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        WatchlistStockList(
          stocks: mockWatchlists[selectedWatchlistIndex],
          onStockTap: widget.onStockTap,
        ),
      ],
    );
  }
}
