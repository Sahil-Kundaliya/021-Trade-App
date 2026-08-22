import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../market/presentation/widgets/market_screener.dart';
import '../widgets/dashboard_market_indices.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({this.navigator, super.key});

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
              const AppSectionHeader(title: 'Dashboard'),
              const SizedBox(height: AppSpacing.lg),
              const DashboardMarketIndices(),
              const SizedBox(height: AppSpacing.lg),
              MarketScreener(onItemTap: (_) => navigator?.openFund()),
            ],
          ),
        ),
      ),
    );
  }
}
