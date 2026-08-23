import '../../domain/entities/searchable_fund.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.allFunds = const [],
    this.query = '',
    this.selectedCategory = SearchCategory.all,
    this.visibleFunds = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final List<SearchableFund> allFunds;
  final String query;
  final SearchCategory selectedCategory;
  final List<SearchableFund> visibleFunds;
  final String? errorMessage;

  String get normalizedQuery => query.trim().toLowerCase();
  bool get isSearchActive => normalizedQuery.length >= 3;

  SearchState copyWith({
    SearchStatus? status,
    List<SearchableFund>? allFunds,
    String? query,
    SearchCategory? selectedCategory,
    List<SearchableFund>? visibleFunds,
    String? errorMessage,
    bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    allFunds: allFunds ?? this.allFunds,
    query: query ?? this.query,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    visibleFunds: visibleFunds ?? this.visibleFunds,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
