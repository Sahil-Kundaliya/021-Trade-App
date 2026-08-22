import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../holdings/data/mock_holdings_data.dart';
import '../../../holdings/presentation/widgets/holdings_header.dart';
import '../../../holdings/presentation/widgets/holdings_list.dart';
import '../../../holdings/presentation/widgets/portfolio_summary_card.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(title: 'Portfolio'),
                  const SizedBox(height: AppSpacing.lg),
                  const PortfolioSummaryCard(summary: mockPortfolioSummary),
                  const SizedBox(height: AppSpacing.xxl),
                  const HoldingsHeader(),
                  const SizedBox(height: AppSpacing.md),
                  HoldingsList(
                    holdings: mockHoldings,
                    onHoldingTap: (_) => navigator?.openFund(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
