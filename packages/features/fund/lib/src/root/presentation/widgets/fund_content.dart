import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../funds/data/mock_fund_data.dart';
import '../../../funds/presentation/widgets/collateral_section.dart';
import '../../../funds/presentation/widgets/fund_balance_card.dart';
import '../../../funds/presentation/widgets/fund_summary_section.dart';
import '../../../funds/presentation/widgets/margin_breakdown_section.dart';
import '../../../funds/presentation/widgets/recent_fund_activity.dart';

class FundContent extends StatelessWidget {
  const FundContent({
    required this.onBuy,
    required this.onSell,
    this.scrollController,
    this.onClose,
    this.showDragHandle = false,
    super.key,
  });

  final VoidCallback onBuy;
  final VoidCallback onSell;
  final ScrollController? scrollController;
  final VoidCallback? onClose;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDragHandle) ...[
                  Center(
                    child: Container(
                      width: AppSizes.buttonHeightSm,
                      height: AppRadius.xs,
                      decoration: BoxDecoration(
                        color: context.appColors.border,
                        borderRadius: AppRadius.pillBorderRadius,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppSectionHeader(
                  title: 'Funds',
                  trailing: onClose == null
                      ? IconButton(
                          tooltip: 'More fund options',
                          onPressed: _noOp,
                          icon: const Icon(Icons.more_vert),
                        )
                      : IconButton(
                          tooltip: 'Close funds',
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FundBalanceCard(
                  summary: mockFundSummary,
                  onBuy: onBuy,
                  onSell: onSell,
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
                          CollateralSection(collateral: mockCollateralSummary),
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
      ],
    );
  }

  static void _noOp() {}
}
