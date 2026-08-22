import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../root/presentation/widgets/watchlist_market_indices.dart';
import '../../watchlist/presentation/widgets/watchlist_header.dart';
import '../../watchlist/presentation/widgets/watchlist_section.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WatchlistHeader(),
              SizedBox(height: AppSpacing.lg),
              WatchlistMarketIndices(),
              SizedBox(height: AppSpacing.lg),
              WatchlistSection(),
            ],
          ),
        ),
      ),
    );
  }
}
