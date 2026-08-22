import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../root/presentation/widgets/watchlist_market_indices.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              WatchlistMarketIndices(),
              Expanded(child: AppEmptyState(title: 'Watchlist')),
            ],
          ),
        ),
      ),
    );
  }
}
