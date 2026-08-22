import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/margin_breakdown.dart';
import '../formatters/fund_currency_format.dart';
import 'fund_breakdown_row.dart';

class MarginBreakdownSection extends StatelessWidget {
  const MarginBreakdownSection({required this.margin, super.key});

  final MarginBreakdown margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Margin Used'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              FundBreakdownRow(
                label: 'Total Margin Used',
                value: FundCurrencyFormat.currency(margin.total),
                emphasized: true,
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'SPAN',
                value: FundCurrencyFormat.currency(margin.span),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Exposure',
                value: FundCurrencyFormat.currency(margin.exposure),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Option Premium',
                value: FundCurrencyFormat.currency(margin.optionPremium),
              ),
              const AppDivider(),
              FundBreakdownRow(
                label: 'Delivery Margin',
                value: FundCurrencyFormat.currency(margin.deliveryMargin),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
