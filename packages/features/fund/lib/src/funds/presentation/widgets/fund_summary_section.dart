import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/fund_summary.dart';
import '../formatters/fund_currency_format.dart';
import 'fund_breakdown_row.dart';

class FundSummarySection extends StatelessWidget {
  const FundSummarySection({required this.summary, super.key});

  final FundSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Funds Summary'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              FundBreakdownRow(
                label: 'Available Cash',
                value: FundCurrencyFormat.currency(summary.availableCash),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Used Margin',
                value: FundCurrencyFormat.currency(summary.usedMargin),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Opening Balance',
                value: FundCurrencyFormat.currency(summary.openingBalance),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Added Today',
                value: FundCurrencyFormat.signedCurrency(
                  summary.addedToday,
                  isCredit: true,
                ),
                valueColor: context.appColors.positive,
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Withdrawn Today',
                value: FundCurrencyFormat.signedCurrency(
                  summary.withdrawnToday,
                  isCredit: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
