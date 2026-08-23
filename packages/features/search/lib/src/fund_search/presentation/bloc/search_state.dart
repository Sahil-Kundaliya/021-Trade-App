import '../../domain/entities/searchable_fund.dart';
import 'package:core_data/core_data.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.allFunds = const [],
    this.query = '',
    this.selectedCategory = SearchCategory.all,
    this.visibleFunds = const [],
    this.livePrices = const {},
    this.errorMessage,
  });

  final SearchStatus status;
  final List<SearchableFund> allFunds;
  final String query;
  final SearchCategory selectedCategory;
  final List<SearchableFund> visibleFunds;
  final Map<String, LivePriceTick> livePrices;
  final String? errorMessage;

  String get normalizedQuery => query.trim().toLowerCase();
  bool get isSearchActive => normalizedQuery.length >= 3;

  SearchState copyWith({
    SearchStatus? status,
    List<SearchableFund>? allFunds,
    String? query,
    SearchCategory? selectedCategory,
    List<SearchableFund>? visibleFunds,
    Map<String, LivePriceTick>? livePrices,
    String? errorMessage,
    bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    allFunds: allFunds ?? this.allFunds,
    query: query ?? this.query,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    visibleFunds: visibleFunds ?? this.visibleFunds,
    livePrices: livePrices ?? this.livePrices,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
