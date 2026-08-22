import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/collateral_summary.dart';
import '../formatters/fund_currency_format.dart';
import 'fund_breakdown_row.dart';

class CollateralSection extends StatelessWidget {
  const CollateralSection({required this.collateral, super.key});

  final CollateralSummary collateral;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Collateral'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              FundBreakdownRow(
                label: 'Total Collateral',
                value: FundCurrencyFormat.currency(collateral.total),
                emphasized: true,
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Equity Collateral',
                value: FundCurrencyFormat.currency(collateral.equity),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Liquid Collateral',
                value: FundCurrencyFormat.currency(collateral.liquid),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
