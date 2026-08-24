import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../holdings/presentation/bloc/holdings_bloc.dart';
import '../../../holdings/presentation/bloc/holdings_event.dart';
import '../../../holdings/presentation/bloc/holdings_state.dart';
import '../../../holdings/presentation/widgets/holdings_header.dart';
import '../../../holdings/presentation/widgets/holdings_empty_state.dart';
import '../../../holdings/presentation/widgets/holdings_list.dart';
import '../../../holdings/presentation/widgets/portfolio_summary_card.dart';
import '../../../holdings/domain/entities/holding.dart';
import '../../../holdings/domain/entities/portfolio_summary.dart';
import 'package:core_data/core_data.dart';
import 'portfolio_skeleton.dart';

class PortfolioContent extends StatelessWidget {
  const PortfolioContent({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HoldingsBloc, HoldingsState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.sort != current.sort ||
              previous.selectedCategory != current.selectedCategory ||
              previous.availableCategories != current.availableCategories ||
              previous.errorMessage != current.errorMessage ||
              !_sameHoldingKeys(previous, current),
          builder: (context, state) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PageWidth(
                    child: AppSectionHeader(
                      title: 'Portfolio',
                      level: AppSectionHeaderLevel.page,
                      trailing: AppIconButton(
                        tooltip: 'Search funds',
                        onPressed: navigator?.openSearch,
                        icon: const Icon(Icons.search, size: AppSizes.iconXs),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              switch (state.status) {
                HoldingsStatus.empty => _CenteredPortfolioState(
                  child: HoldingsEmptyState(
                    onExplore: navigator == null
                        ? null
                        : () => navigator!.openSearch(),
                  ),
                ),
                HoldingsStatus.error => _CenteredPortfolioState(
                  child: _HoldingsError(
                    onRetry: () => context.read<HoldingsBloc>().add(
                      const HoldingsRetryRequested(),
                    ),
                  ),
                ),
                _ => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _PageWidth(
                      child: switch (state.status) {
                        HoldingsStatus.initial ||
                        HoldingsStatus.loading => const PortfolioSkeleton(),
                        HoldingsStatus.loaded => _LoadedPortfolio(
                          state: state,
                          onHoldingTap: (holding) => navigator?.openFund(
                            fundId: holding.fundId,
                            exchange: holding.tradeExchange,
                          ),
                        ),
                        HoldingsStatus.empty ||
                        HoldingsStatus.error => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredPortfolioState extends StatelessWidget {
  const _CenteredPortfolioState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    sliver: SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: child,
        ),
      ),
    ),
  );
}

class _PageWidth extends StatelessWidget {
  const _PageWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 960),
      child: child,
    ),
  );
}

class _LoadedPortfolio extends StatelessWidget {
  const _LoadedPortfolio({required this.state, required this.onHoldingTap});

  final HoldingsState state;
  final ValueChanged<Holding> onHoldingTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BlocSelector<HoldingsBloc, HoldingsState, PortfolioSummary?>(
        selector: (state) => state.summary,
        builder: (context, summary) => summary == null
            ? const SizedBox.shrink()
            : PortfolioSummaryCard(summary: summary),
      ),
      const SizedBox(height: AppSpacing.lg),
      _PortfolioCategoryTabs(state: state),
      const SizedBox(height: AppSpacing.lg),
      HoldingsHeader(
        sort: state.sort,
        onSortChanged: (sort) =>
            context.read<HoldingsBloc>().add(HoldingsSortChanged(sort)),
      ),
      const SizedBox(height: AppSpacing.md),
      AnimatedSwitcher(
        duration: context.motionDuration(AppMotion.short),
        switchInCurve: AppMotionCurves.enter,
        switchOutCurve: AppMotionCurves.exit,
        child: HoldingsList(
          key: ValueKey((
            state.selectedCategory,
            state.sort,
            state.visibleHoldings.map((holding) => holding.fundId).join(','),
          )),
          holdings: state.visibleHoldings,
          onHoldingTap: onHoldingTap,
        ),
      ),
    ],
  );
}

class _PortfolioCategoryTabs extends StatelessWidget {
  const _PortfolioCategoryTabs({required this.state});

  final HoldingsState state;

  @override
  Widget build(BuildContext context) {
    final categories = state.availableCategories;
    final selected = state.selectedCategory!;
    final selectedIndex = categories.indexOf(selected);
    return DefaultTabController(
      key: ValueKey('${categories.join(',')}:${selected.name}'),
      length: categories.length,
      initialIndex: selectedIndex,
      child: TabBar(
        isScrollable: categories.length < 3,
        tabAlignment: categories.length < 3 ? TabAlignment.start : null,
        onTap: (index) => context.read<HoldingsBloc>().add(
          HoldingsCategoryChanged(categories[index]),
        ),
        tabs: [for (final category in categories) Tab(text: _label(category))],
      ),
    );
  }

  static String _label(PortfolioCategory category) => switch (category) {
    PortfolioCategory.equity => 'Equity',
    PortfolioCategory.future => 'Futures',
    PortfolioCategory.options => 'Options',
  };
}

class _HoldingsError extends StatelessWidget {
  const _HoldingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppErrorState(
    title: 'Unable to load holdings',
    description: 'Please try loading your portfolio again.',
    onRetry: onRetry,
  );
}

bool _sameHoldingKeys(HoldingsState previous, HoldingsState current) {
  final left = previous.visibleHoldings;
  final right = current.visibleHoldings;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index].marketKey != right[index].marketKey) return false;
  }
  return true;
}
