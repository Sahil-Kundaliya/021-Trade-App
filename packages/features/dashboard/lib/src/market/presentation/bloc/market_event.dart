import 'package:core_data/core_data.dart';

import '../../domain/entities/market_category.dart';
import '../../domain/entities/market_subcategory.dart';

sealed class MarketEvent {
  const MarketEvent();
}

final class MarketStarted extends MarketEvent {
  const MarketStarted();
}

final class MarketCategoryChanged extends MarketEvent {
  const MarketCategoryChanged(this.category);

  final MarketCategory category;
}

final class MarketSubcategoryChanged extends MarketEvent {
  const MarketSubcategoryChanged(this.subcategory);

  final MarketSubcategory subcategory;
}

final class MarketExchangeChanged extends MarketEvent {
  const MarketExchangeChanged(this.exchange);

  final TradeExchange exchange;
}

final class MarketRetryRequested extends MarketEvent {
  const MarketRetryRequested();
}

final class MarketLivePricesReceived extends MarketEvent {
  const MarketLivePricesReceived(this.batch);

  final LivePriceBatch batch;
}
