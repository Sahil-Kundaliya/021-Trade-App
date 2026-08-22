enum MarketSubcategory {
  topGainers,
  topLosers,
  mostActive,
  callMovers,
  putMovers,
}

extension MarketSubcategoryLabel on MarketSubcategory {
  String get label => switch (this) {
    MarketSubcategory.topGainers => 'Top Gainers',
    MarketSubcategory.topLosers => 'Top Losers',
    MarketSubcategory.mostActive => 'Most Active',
    MarketSubcategory.callMovers => 'Call Movers',
    MarketSubcategory.putMovers => 'Put Movers',
  };
}
