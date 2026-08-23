import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/searchable_fund.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class FundSearchField extends StatefulWidget {
  const FundSearchField({super.key});

  @override
  State<FundSearchField> createState() => _FundSearchFieldState();
}

class _FundSearchFieldState extends State<FundSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<SearchBloc>().state.query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        SearchBloc,
        SearchState,
        ({String query, SearchCategory category})
      >(
        selector: (state) =>
            (query: state.query, category: state.selectedCategory),
        builder: (context, selection) => AppSearchField(
          controller: _controller,
          autofocus: true,
          showSearchIcon: false,
          hintText: switch (selection.category) {
            SearchCategory.all => 'Search Fund',
            SearchCategory.equity => 'Search Equity',
            SearchCategory.future => 'Search Futures',
            SearchCategory.options => 'Search Options',
          },
          onChanged: (value) =>
              context.read<SearchBloc>().add(SearchQueryChanged(query: value)),
          onClear: selection.query.isEmpty
              ? null
              : () {
                  _controller.clear();
                  context.read<SearchBloc>().add(
                    const SearchQueryChanged(query: ''),
                  );
                },
        ),
      );
}
