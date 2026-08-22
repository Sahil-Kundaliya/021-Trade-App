import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../funds/data/mock_fund_data.dart';
import '../../../funds/presentation/widgets/collateral_section.dart';
import '../../../funds/presentation/widgets/fund_balance_card.dart';
import '../../../funds/presentation/widgets/fund_summary_section.dart';
import '../../../funds/presentation/widgets/margin_breakdown_section.dart';
import '../../../funds/presentation/widgets/recent_fund_activity.dart';

class FundPage extends StatelessWidget {
  const FundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: 'Funds',
                    trailing: IconButton(
                      tooltip: 'More fund options',
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FundBalanceCard(
                    summary: mockFundSummary,
                    onAddFunds: _noOp,
                    onWithdraw: _noOp,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 760) {
                        return const Column(
                          children: [
                            FundSummarySection(summary: mockFundSummary),
                            SizedBox(height: AppSpacing.xxl),
                            CollateralSection(
                              collateral: mockCollateralSummary,
                            ),
                            SizedBox(height: AppSpacing.xxl),
                            MarginBreakdownSection(margin: mockMarginBreakdown),
                          ],
                        );
                      }

                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FundSummarySection(summary: mockFundSummary),
                          ),
                          SizedBox(width: AppSpacing.xxl),
                          Expanded(
                            child: Column(
                              children: [
                                CollateralSection(
                                  collateral: mockCollateralSummary,
                                ),
                                SizedBox(height: AppSpacing.xxl),
                                MarginBreakdownSection(
                                  margin: mockMarginBreakdown,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const RecentFundActivity(activities: mockFundActivities),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _noOp() {}
}
