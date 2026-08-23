import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../fund_search/presentation/bloc/search_bloc.dart';
import '../../../fund_search/presentation/bloc/search_event.dart';
import '../../../fund_search/presentation/bloc/search_state.dart';
import '../../../fund_search/presentation/widgets/fund_category_filter.dart';
import '../../../fund_search/presentation/widgets/fund_search_field.dart';
import '../../../fund_search/presentation/widgets/fund_search_results.dart';

class SearchContent extends StatelessWidget {
  const SearchContent({required this.navigator, super.key});

  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: AppSpacing.none,
      title: const Padding(
        padding: EdgeInsets.only(right: AppSpacing.lg),
        child: FundSearchField(),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: BlocSelector<SearchBloc, SearchState, SearchStatus>(
            selector: (state) => state.status,
            builder: (context, status) => switch (status) {
              SearchStatus.initial || SearchStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              SearchStatus.error => AppEmptyState(
                title: 'Unable to load funds',
                description: 'Please try loading local instruments again.',
                action: AppButton(
                  label: 'Retry',
                  onPressed: () => context.read<SearchBloc>().add(
                    const SearchRetryRequested(),
                  ),
                ),
              ),
              SearchStatus.loaded => _LoadedSearch(navigator: navigator),
            },
          ),
        ),
      ),
    ),
  );
}

class _LoadedSearch extends StatelessWidget {
  const _LoadedSearch({required this.navigator});

  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.none,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FundCategoryFilter(),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: FundSearchResults(navigator: navigator)),
      ],
    ),
  );
}
