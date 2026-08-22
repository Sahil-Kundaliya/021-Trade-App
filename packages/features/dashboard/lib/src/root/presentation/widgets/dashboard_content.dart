import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../market/presentation/bloc/market_bloc.dart';
import '../../../market/presentation/bloc/market_event.dart';
import '../../../market/presentation/bloc/market_state.dart';
import '../../../market/presentation/widgets/market_screener.dart';
import 'dashboard_market_indices.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(title: 'Dashboard'),
              const SizedBox(height: AppSpacing.lg),
              const DashboardMarketIndices(),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<MarketBloc, MarketState>(
                builder: (context, state) => switch (state.status) {
                  MarketStatus.initial ||
                  MarketStatus.loading => const _MarketLoading(),
                  MarketStatus.error => _MarketError(
                    onRetry: () => context.read<MarketBloc>().add(
                      const MarketRetryRequested(),
                    ),
                  ),
                  MarketStatus.empty => const _MarketEmpty(),
                  MarketStatus.loaded => MarketScreener(
                    selectedCategory: state.selectedCategory,
                    selectedSubcategory: state.selectedSubcategory,
                    instruments: state.visibleFunds,
                    onCategorySelected: (category) => context
                        .read<MarketBloc>()
                        .add(MarketCategoryChanged(category)),
                    onSubcategorySelected: (subcategory) => context
                        .read<MarketBloc>()
                        .add(MarketSubcategoryChanged(subcategory)),
                    onItemTap: (_) => navigator?.openFund(),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketLoading extends StatelessWidget {
  const _MarketLoading();

  @override
  Widget build(BuildContext context) => const AppCard(
    child: SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _MarketEmpty extends StatelessWidget {
  const _MarketEmpty();

  @override
  Widget build(BuildContext context) => const AppCard(
    child: AppEmptyState(
      title: 'No market data available',
      description: 'Market instruments will appear here when available.',
    ),
  );
}

class _MarketError extends StatelessWidget {
  const _MarketError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        const Text('Unable to load market data'),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: 'Retry', onPressed: onRetry),
      ],
    ),
  );
}
