import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/searchable_fund.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class FundCategoryFilter extends StatelessWidget {
  const FundCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SearchBloc, SearchState, SearchCategory>(
        selector: (state) => state.selectedCategory,
        builder: (context, selected) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in SearchCategory.values) ...[
                AppChip(
                  label: category.label,
                  selected: category == selected,
                  onSelected: (_) => context.read<SearchBloc>().add(
                    SearchCategoryChanged(category),
                  ),
                ),
                if (category != SearchCategory.values.last)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      );
}
