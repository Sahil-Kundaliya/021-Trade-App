import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../domain/entities/searchable_fund.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';
import 'search_fund_tile.dart';

class FundSearchResults extends StatelessWidget {
  const FundSearchResults({required this.navigator, super.key});

  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SearchBloc, SearchState, _ResultsViewData>(
        selector: _ResultsViewData.fromState,
        builder: (context, data) => AnimatedSwitcher(
          duration: AppDurations.normal,
          child: Column(
            key: ValueKey((data.isSearchActive, data.query.length)),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.isSearchActive
                    ? 'SEARCH RESULTS • ${data.funds.length}'
                    : 'TRADING FUNDS',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.appColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!data.isSearchActive && data.query.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter at least 3 characters to search',
                  style: context.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: data.isSearchActive && data.funds.isEmpty
                    ? const AppEmptyState(
                        title: 'No funds found',
                        description: 'Try another symbol or company name.',
                        icon: Icons.search_off,
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: data.funds.length,
                        separatorBuilder: (_, _) => const AppDivider(),
                        itemBuilder: (context, index) {
                          final fund = data.funds[index];
                          return SearchFundTile(
                            key: ValueKey(fund.marketKey),
                            fund: fund,
                            onTap: () => navigator.openFund(
                              fundId: fund.id,
                              exchange: fund.exchange,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
}

class _ResultsViewData {
  const _ResultsViewData({
    required this.funds,
    required this.query,
    required this.isSearchActive,
  });

  factory _ResultsViewData.fromState(SearchState state) => _ResultsViewData(
    funds: state.visibleFunds,
    query: state.query,
    isSearchActive: state.isSearchActive,
  );

  final List<SearchableFund> funds;
  final String query;
  final bool isSearchActive;

  @override
  bool operator ==(Object other) =>
      other is _ResultsViewData &&
      identical(other.funds, funds) &&
      other.query == query &&
      other.isSearchActive == isSearchActive;

  @override
  int get hashCode =>
      Object.hash(identityHashCode(funds), query, isSearchActive);
}
