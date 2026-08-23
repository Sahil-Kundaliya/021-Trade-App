import 'package:core_data/core_data.dart';

import '../../domain/entities/searchable_fund.dart';

sealed class SearchEvent {
  const SearchEvent();
}

final class SearchStarted extends SearchEvent {
  const SearchStarted();
}

final class SearchRetryRequested extends SearchEvent {
  const SearchRetryRequested();
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged({required this.query});

  final String query;
}

final class SearchCategoryChanged extends SearchEvent {
  const SearchCategoryChanged(this.category);

  final SearchCategory category;
}

final class SearchLivePricesReceived extends SearchEvent {
  const SearchLivePricesReceived(this.batch);

  final LivePriceBatch batch;
}
