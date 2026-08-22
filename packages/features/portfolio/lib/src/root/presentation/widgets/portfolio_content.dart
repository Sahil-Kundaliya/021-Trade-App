import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../holdings/presentation/bloc/holdings_bloc.dart';
import '../../../holdings/presentation/bloc/holdings_event.dart';
import '../../../holdings/presentation/bloc/holdings_state.dart';
import '../../../holdings/presentation/widgets/holdings_header.dart';
import '../../../holdings/presentation/widgets/holdings_list.dart';
import '../../../holdings/presentation/widgets/portfolio_summary_card.dart';
import '../../../holdings/domain/entities/holding.dart';

class PortfolioContent extends StatelessWidget {
  const PortfolioContent({this.navigator, super.key});

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
              child: BlocBuilder<HoldingsBloc, HoldingsState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: 'Portfolio'),
                    const SizedBox(height: AppSpacing.lg),
                    switch (state.status) {
                      HoldingsStatus.initial ||
                      HoldingsStatus.loading => const _HoldingsLoading(),
                      HoldingsStatus.error => _HoldingsError(
                        onRetry: () => context.read<HoldingsBloc>().add(
                          const HoldingsRetryRequested(),
                        ),
                      ),
                      HoldingsStatus.empty => const HoldingsList(holdings: []),
                      HoldingsStatus.loaded => _LoadedPortfolio(
                        state: state,
                        onHoldingTap: (holding) =>
                            navigator?.openFund(fundId: holding.fundId),
                      ),
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedPortfolio extends StatelessWidget {
  const _LoadedPortfolio({required this.state, required this.onHoldingTap});

  final HoldingsState state;
  final ValueChanged<Holding> onHoldingTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PortfolioSummaryCard(summary: state.summary!),
      const SizedBox(height: AppSpacing.xxl),
      HoldingsHeader(
        sort: state.sort,
        onSortChanged: (sort) =>
            context.read<HoldingsBloc>().add(HoldingsSortChanged(sort)),
      ),
      const SizedBox(height: AppSpacing.md),
      HoldingsList(holdings: state.holdings, onHoldingTap: onHoldingTap),
    ],
  );
}

class _HoldingsLoading extends StatelessWidget {
  const _HoldingsLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 260,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _HoldingsError extends StatelessWidget {
  const _HoldingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: 'Unable to load holdings',
    description: 'Please try loading your portfolio again.',
    action: AppButton(label: 'Retry', onPressed: onRetry),
  );
}
