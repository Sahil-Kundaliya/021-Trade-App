import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/holding.dart';
import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_state.dart';
import '../formatters/portfolio_number_format.dart';

class HoldingTile extends StatelessWidget {
  const HoldingTile({required this.holding, this.onTap, super.key});

  final Holding holding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HoldingsBloc, HoldingsState, Holding>(
      selector: (state) {
        for (final item in state.holdings) {
          if (item.marketKey == holding.marketKey) return item;
        }
        return holding;
      },
      builder: (context, live) => _HoldingBody(holding: live, onTap: onTap),
    );
  }
}

class _HoldingBody extends StatelessWidget {
  const _HoldingBody({required this.holding, this.onTap});

  final Holding holding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pnlColor = holding.pnl >= 0
        ? context.appColors.positive
        : context.appColors.negative;

    return Semantics(
      button: onTap != null,
      label: PrivacyModeScope.of(context)
          ? '${holding.symbol}, ${holding.companyName}, position values hidden, LTP ${PortfolioNumberFormat.currency(holding.ltp)}'
          : '${holding.symbol}, ${holding.companyName}, quantity ${holding.quantity}, profit and loss ${PortfolioNumberFormat.signedCurrency(holding.pnl)}, ${PortfolioNumberFormat.percentage(holding.pnlPercent)}',
      child: Material(
        color: context.appColors.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 700) {
                  return _WideHoldingLayout(
                    holding: holding,
                    pnlColor: pnlColor,
                  );
                }
                return _CompactHoldingLayout(
                  holding: holding,
                  pnlColor: pnlColor,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactHoldingLayout extends StatelessWidget {
  const _CompactHoldingLayout({required this.holding, required this.pnlColor});

  final Holding holding;
  final Color pnlColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _HoldingIdentity(holding: holding)),
            const SizedBox(width: AppSpacing.md),
            _PnlValue(holding: holding, color: pnlColor),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _InlineMetric(
                label: 'Qty',
                value: holding.quantity.toString(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _InlineMetric(
                label: 'Avg',
                value: PortfolioNumberFormat.currency(holding.averageCost),
                alignment: MainAxisAlignment.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _LtpMetric(holding: holding)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ValueMetric(
                label: 'Current Value',
                value: PortfolioNumberFormat.currency(holding.currentValue),
                crossAxisAlignment: CrossAxisAlignment.end,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideHoldingLayout extends StatelessWidget {
  const _WideHoldingLayout({required this.holding, required this.pnlColor});

  final Holding holding;
  final Color pnlColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _HoldingIdentity(holding: holding)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _ValueMetric(label: 'Qty', value: holding.quantity.toString()),
        ),
        Expanded(
          flex: 2,
          child: _ValueMetric(
            label: 'Avg Cost',
            value: PortfolioNumberFormat.currency(holding.averageCost),
          ),
        ),
        Expanded(flex: 2, child: _LtpMetric(holding: holding)),
        Expanded(
          flex: 2,
          child: _ValueMetric(
            label: 'Current Value',
            value: PortfolioNumberFormat.currency(holding.currentValue),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.topRight,
            child: _PnlValue(holding: holding, color: pnlColor),
          ),
        ),
      ],
    );
  }
}

class _HoldingIdentity extends StatelessWidget {
  const _HoldingIdentity({required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          holding.symbol,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          holding.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PnlValue extends StatelessWidget {
  const _PnlValue({required this.holding, required this.color});

  final Holding holding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'P&L',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SensitiveValueText(
          PortfolioNumberFormat.signedCurrency(holding.pnl),
          type: SensitiveValueType.currency,
          maxLines: 1,
          style: context.appTextStyles.marketValueMedium.copyWith(color: color),
        ),
        SensitiveValueText(
          PortfolioNumberFormat.percentage(holding.pnlPercent),
          type: SensitiveValueType.percentage,
          style: context.appTextStyles.percentageSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.label,
    required this.value,
    this.alignment = MainAxisAlignment.start,
  });

  final String label;
  final String value;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: SensitiveValueText(
            value,
            type: label == 'Qty'
                ? SensitiveValueType.quantity
                : SensitiveValueType.currency,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: context.appTextStyles.tableValue.copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LtpMetric extends StatelessWidget {
  const _LtpMetric({required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final change = holding.ltp - holding.previousClose;
    final changePercent = holding.previousClose == 0
        ? 0.0
        : change / holding.previousClose * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LTP',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTextStyles.tableHeader.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        MarketQuote(
          ltp: holding.ltp,
          change: change,
          changePercent: changePercent,
          alignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }
}

class _ValueMetric extends StatelessWidget {
  const _ValueMetric({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTextStyles.tableHeader.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SensitiveValueText(
          value,
          type: label == 'Qty'
              ? SensitiveValueType.quantity
              : SensitiveValueType.currency,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          textAlign: textAlign,
          style: context.appTextStyles.tableValue.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
