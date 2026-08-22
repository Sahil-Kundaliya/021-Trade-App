import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../holdings/data/mock_holdings_data.dart';
import '../../../holdings/presentation/widgets/holdings_header.dart';
import '../../../holdings/presentation/widgets/holdings_list.dart';
import '../../../holdings/presentation/widgets/portfolio_summary_card.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(title: 'Portfolio'),
                  SizedBox(height: AppSpacing.lg),
                  PortfolioSummaryCard(summary: mockPortfolioSummary),
                  SizedBox(height: AppSpacing.xxl),
                  HoldingsHeader(),
                  SizedBox(height: AppSpacing.md),
                  HoldingsList(holdings: mockHoldings),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
