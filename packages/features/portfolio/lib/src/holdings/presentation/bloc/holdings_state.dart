import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import 'holdings_sort.dart';
import 'package:core_data/core_data.dart';

enum HoldingsStatus { initial, loading, loaded, empty, error }

class HoldingsState {
  const HoldingsState({
    this.status = HoldingsStatus.initial,
    this.holdings = const [],
    this.summary,
    this.sort = HoldingsSort.pnlDescending,
    this.errorMessage,
    this.availableCategories = const [],
    this.selectedCategory,
    this.livePrices = const {},
  });

  final HoldingsStatus status;
  final List<Holding> holdings;
  final PortfolioSummary? summary;
  final HoldingsSort sort;
  final String? errorMessage;
  final List<PortfolioCategory> availableCategories;
  final PortfolioCategory? selectedCategory;
  final Map<String, LivePriceTick> livePrices;
  List<Holding> get visibleHoldings => selectedCategory == null
      ? const []
      : holdings
            .where((holding) => holding.category == selectedCategory)
            .toList(growable: false);

  HoldingsState copyWith({
    HoldingsStatus? status,
    List<Holding>? holdings,
    PortfolioSummary? summary,
    HoldingsSort? sort,
    String? errorMessage,
    bool clearError = false,
    List<PortfolioCategory>? availableCategories,
    PortfolioCategory? selectedCategory,
    bool clearSelectedCategory = false,
    Map<String, LivePriceTick>? livePrices,
  }) => HoldingsState(
    status: status ?? this.status,
    holdings: holdings ?? this.holdings,
    summary: summary ?? this.summary,
    sort: sort ?? this.sort,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    availableCategories: availableCategories ?? this.availableCategories,
    selectedCategory: clearSelectedCategory
        ? null
        : selectedCategory ?? this.selectedCategory,
    livePrices: livePrices ?? this.livePrices,
  );
}
