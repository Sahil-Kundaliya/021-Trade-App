import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_instrument.dart';
import '../../domain/entities/market_subcategory.dart';
import 'package:core_data/core_data.dart';

enum MarketStatus { initial, loading, loaded, empty, error }

class MarketState {
  const MarketState({
    this.status = MarketStatus.initial,
    this.allFunds = const [],
    this.selectedCategory = MarketCategory.equity,
    this.selectedSubcategory = MarketSubcategory.topGainers,
    this.selectedExchange = TradeExchange.nse,
    this.visibleFunds = const [],
    this.livePrices = const {},
    this.errorMessage,
  });

  final MarketStatus status;
  final List<MarketInstrument> allFunds;
  final MarketCategory selectedCategory;
  final MarketSubcategory selectedSubcategory;
  final TradeExchange selectedExchange;
  final List<MarketInstrument> visibleFunds;
  final Map<String, LivePriceTick> livePrices;
  final String? errorMessage;

  MarketState copyWith({
    MarketStatus? status,
    List<MarketInstrument>? allFunds,
    MarketCategory? selectedCategory,
    MarketSubcategory? selectedSubcategory,
    TradeExchange? selectedExchange,
    List<MarketInstrument>? visibleFunds,
    Map<String, LivePriceTick>? livePrices,
    String? errorMessage,
    bool clearError = false,
  }) => MarketState(
    status: status ?? this.status,
    allFunds: allFunds ?? this.allFunds,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
    selectedExchange: selectedExchange ?? this.selectedExchange,
    visibleFunds: visibleFunds ?? this.visibleFunds,
    livePrices: livePrices ?? this.livePrices,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
