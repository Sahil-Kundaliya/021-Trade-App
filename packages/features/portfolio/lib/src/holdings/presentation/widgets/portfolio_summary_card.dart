import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/portfolio_summary.dart';
import '../formatters/portfolio_number_format.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({required this.summary, super.key});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final pnlColor = summary.totalPnl >= 0
        ? context.appColors.positive
        : context.appColors.negative;
    final pnlLabel = summary.totalPnl >= 0
        ? 'Unrealised Gain'
        : 'Unrealised Loss';

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final overview = _PortfolioOverview(summary: summary);
          final pnl = _PortfolioPnl(
            summary: summary,
            color: pnlColor,
            label: pnlLabel,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth >= 560)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: overview),
                    const SizedBox(width: AppSpacing.xxl),
                    pnl,
                  ],
                )
              else ...[
                overview,
                const SizedBox(height: AppSpacing.lg),
                pnl,
              ],
              const SizedBox(height: AppSpacing.lg),
              const AppDivider(),
              const SizedBox(height: AppSpacing.lg),
              _SummaryMetrics(summary: summary),
            ],
          );
        },
      ),
    );
  }
}

class _PortfolioOverview extends StatelessWidget {
  const _PortfolioOverview({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: PrivacyModeScope.of(context)
          ? 'Portfolio value hidden'
          : 'Portfolio value ${PortfolioNumberFormat.currency(summary.currentValue)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Value',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SensitiveValueText(
            PortfolioNumberFormat.currency(summary.currentValue),
            type: SensitiveValueType.currency,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: context.appTextStyles.marketValueLarge.copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioPnl extends StatelessWidget {
  const _PortfolioPnl({
    required this.summary,
    required this.color,
    required this.label,
  });

  final PortfolioSummary summary;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: PrivacyModeScope.of(context)
          ? '$label, values hidden'
          : '$label, ${PortfolioNumberFormat.signedCurrency(summary.totalPnl)}, ${PortfolioNumberFormat.percentage(summary.totalPnlPercent)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              SensitiveValueText(
                PortfolioNumberFormat.signedCurrency(summary.totalPnl),
                type: SensitiveValueType.currency,
                style: context.appTextStyles.marketValueMedium.copyWith(
                  color: color,
                ),
              ),
              SensitiveValueText(
                PortfolioNumberFormat.percentage(summary.totalPnlPercent),
                type: SensitiveValueType.percentage,
                style: context.appTextStyles.percentageMedium.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final invested = _SummaryMetric(
          label: 'Total Invested',
          value: PortfolioNumberFormat.currency(summary.totalInvested),
        );
        final current = _SummaryMetric(
          label: 'Current Value',
          value: PortfolioNumberFormat.currency(summary.currentValue),
          textAlign: TextAlign.end,
          crossAxisAlignment: CrossAxisAlignment.end,
        );

        if (constraints.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              invested,
              const SizedBox(height: AppSpacing.md),
              _SummaryMetric(
                label: 'Current Value',
                value: PortfolioNumberFormat.currency(summary.currentValue),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: invested),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: current),
          ],
        );
      },
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SensitiveValueText(
          value,
          type: SensitiveValueType.currency,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          textAlign: textAlign,
          style: context.appTextStyles.marketValueMedium.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
