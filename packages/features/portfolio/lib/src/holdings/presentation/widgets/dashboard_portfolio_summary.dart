import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/portfolio_summary.dart';
import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_event.dart';
import '../bloc/holdings_state.dart';
import '../formatters/portfolio_number_format.dart';

class DashboardPortfolioSummary extends StatelessWidget {
  const DashboardPortfolioSummary({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<HoldingsBloc>()..add(const HoldingsStarted()),
    child: _DashboardPortfolioSummaryCard(onTap: onTap),
  );
}

class _DashboardPortfolioSummaryCard extends StatelessWidget {
  const _DashboardPortfolioSummaryCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HoldingsBloc, HoldingsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.summary != current.summary,
      builder: (context, state) => AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Portfolio Summary',
              subtitle: 'Your holdings at a glance',
              level: AppSectionHeaderLevel.card,
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSizes.iconXs,
                color: context.appColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (state.status) {
              HoldingsStatus.initial ||
              HoldingsStatus.loading => const _SummaryLoading(),
              HoldingsStatus.error => _SummaryError(
                onRetry: () => context.read<HoldingsBloc>().add(
                  const HoldingsRetryRequested(),
                ),
              ),
              HoldingsStatus.empty => const _SummaryValues(
                summary: PortfolioSummary(
                  totalInvested: 0,
                  currentValue: 0,
                  totalPnl: 0,
                  totalPnlPercent: 0,
                ),
              ),
              HoldingsStatus.loaded => _SummaryValues(summary: state.summary!),
            },
          ],
        ),
      ),
    );
  }
}

class _SummaryValues extends StatelessWidget {
  const _SummaryValues({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Current Value',
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
        style: context.appTextStyles.financialHero.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      const AppDivider(),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Invested Value',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      SensitiveValueText(
        PortfolioNumberFormat.currency(summary.totalInvested),
        type: SensitiveValueType.currency,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: context.appTextStyles.marketValueMedium.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
    ],
  );
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonLine(width: 96),
      SizedBox(height: AppSpacing.sm),
      SkeletonLine(width: 190, height: 28),
      SizedBox(height: AppSpacing.lg),
      AppDivider(),
      SizedBox(height: AppSpacing.md),
      SkeletonLine(width: 88),
      SizedBox(height: AppSpacing.xs),
      SkeletonLine(width: 140, height: 18),
    ],
  );
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppErrorState(
    title: 'Portfolio unavailable',
    description: 'Unable to load your portfolio summary.',
    onRetry: onRetry,
  );
}
