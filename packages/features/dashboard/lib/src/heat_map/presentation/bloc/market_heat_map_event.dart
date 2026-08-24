import 'package:core_data/core_data.dart';

sealed class MarketHeatMapEvent {
  const MarketHeatMapEvent();
}

final class MarketHeatMapStarted extends MarketHeatMapEvent {
  const MarketHeatMapStarted(this.exchange);

  final TradeExchange exchange;
}

final class MarketHeatMapExchangeChanged extends MarketHeatMapEvent {
  const MarketHeatMapExchangeChanged(this.exchange);

  final TradeExchange exchange;
}

final class MarketHeatMapRetryRequested extends MarketHeatMapEvent {
  const MarketHeatMapRetryRequested();
}

final class MarketHeatMapLivePricesReceived extends MarketHeatMapEvent {
  const MarketHeatMapLivePricesReceived(this.batch);

  final LivePriceBatch batch;
}
