import 'market_subcategory.dart';

enum MarketCategory { equity, futures, options }

extension MarketCategoryLabel on MarketCategory {
  String get label => switch (this) {
    MarketCategory.equity => 'Equity',
    MarketCategory.futures => 'Futures',
    MarketCategory.options => 'Options',
  };

  List<MarketSubcategory> get subcategories => switch (this) {
    MarketCategory.equity || MarketCategory.futures => const [
      MarketSubcategory.topGainers,
      MarketSubcategory.topLosers,
      MarketSubcategory.mostActive,
    ],
    MarketCategory.options => const [
      MarketSubcategory.mostActive,
      MarketSubcategory.callMovers,
      MarketSubcategory.putMovers,
    ],
  };
}
