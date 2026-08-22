import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../root/presentation/widgets/watchlist_market_indices.dart';
import '../../watchlist/presentation/widgets/watchlist_header.dart';
import '../../watchlist/presentation/widgets/watchlist_section.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WatchlistHeader(),
              const SizedBox(height: AppSpacing.lg),
              const WatchlistMarketIndices(),
              const SizedBox(height: AppSpacing.lg),
              WatchlistSection(onStockTap: (_) => navigator?.openFund()),
            ],
          ),
        ),
      ),
    );
  }
}
