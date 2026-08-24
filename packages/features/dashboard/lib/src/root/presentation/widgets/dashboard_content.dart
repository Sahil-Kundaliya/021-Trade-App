import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../market/presentation/bloc/market_bloc.dart';
import '../../../market/presentation/bloc/market_event.dart';
import '../../../market/presentation/bloc/market_state.dart';
import '../../../market/presentation/widgets/market_screener.dart';
import 'dashboard_market_indices.dart';
import 'dashboard_skeleton.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MarketBloc, MarketState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.selectedCategory != current.selectedCategory ||
              previous.selectedSubcategory != current.selectedSubcategory ||
              previous.selectedExchange != current.selectedExchange ||
              !identical(previous.visibleFunds, current.visibleFunds) ||
              previous.errorMessage != current.errorMessage,
          builder: (context, state) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child:
                state.status == MarketStatus.initial ||
                    state.status == MarketStatus.loading
                ? const DashboardSkeleton()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSectionHeader(
                        title: 'Dashboard',
                        level: AppSectionHeaderLevel.page,
                        trailing: AppIconButton(
                          tooltip: 'Search funds',
                          onPressed: navigator?.openSearch,
                          icon: const Icon(Icons.search, size: AppSizes.iconXs),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const DashboardMarketIndices(),
                      const SizedBox(height: AppSpacing.lg),
                      switch (state.status) {
                        MarketStatus.initial ||
                        MarketStatus.loading => const SizedBox.shrink(),
                        MarketStatus.error => _MarketError(
                          onRetry: () => context.read<MarketBloc>().add(
                            const MarketRetryRequested(),
                          ),
                        ),
                        MarketStatus.empty => const _MarketEmpty(),
                        MarketStatus.loaded => MarketScreener(
                          selectedCategory: state.selectedCategory,
                          selectedSubcategory: state.selectedSubcategory,
                          selectedExchange: state.selectedExchange,
                          instruments: state.visibleFunds,
                          onCategorySelected: (category) => context
                              .read<MarketBloc>()
                              .add(MarketCategoryChanged(category)),
                          onSubcategorySelected: (subcategory) => context
                              .read<MarketBloc>()
                              .add(MarketSubcategoryChanged(subcategory)),
                          onExchangeSelected: (exchange) => context
                              .read<MarketBloc>()
                              .add(MarketExchangeChanged(exchange)),
                          onItemTap: (instrument) => navigator?.openFund(
                            fundId: instrument.id,
                            exchange: instrument.exchange,
                          ),
                        ),
                      },
                    ],
                  ),
          ),
        ),
      ),
    );
  }
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
    child: AppErrorState(
      title: 'Unable to load market data',
      description: 'Please try loading market data again.',
      onRetry: onRetry,
    ),
  );
}
