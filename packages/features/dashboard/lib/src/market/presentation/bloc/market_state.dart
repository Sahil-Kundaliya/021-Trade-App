import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_instrument.dart';
import '../../domain/entities/market_subcategory.dart';

enum MarketStatus { initial, loading, loaded, empty, error }

class MarketState {
  const MarketState({
    this.status = MarketStatus.initial,
    this.allFunds = const [],
    this.selectedCategory = MarketCategory.equity,
    this.selectedSubcategory = MarketSubcategory.topGainers,
    this.visibleFunds = const [],
    this.errorMessage,
  });

  final MarketStatus status;
  final List<MarketInstrument> allFunds;
  final MarketCategory selectedCategory;
  final MarketSubcategory selectedSubcategory;
  final List<MarketInstrument> visibleFunds;
  final String? errorMessage;

  MarketState copyWith({
    MarketStatus? status,
    List<MarketInstrument>? allFunds,
    MarketCategory? selectedCategory,
    MarketSubcategory? selectedSubcategory,
    List<MarketInstrument>? visibleFunds,
    String? errorMessage,
    bool clearError = false,
  }) => MarketState(
    status: status ?? this.status,
    allFunds: allFunds ?? this.allFunds,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
    visibleFunds: visibleFunds ?? this.visibleFunds,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
