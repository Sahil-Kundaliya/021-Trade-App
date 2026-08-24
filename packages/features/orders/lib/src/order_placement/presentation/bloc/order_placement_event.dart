import 'package:core_data/core_data.dart' hide TradeExchange;
import 'package:navigation_contract/navigation_contract.dart' show TradeSide;

import '../../domain/enums/order_enums.dart';

sealed class OrderPlacementEvent {
  const OrderPlacementEvent();
}

final class OrderPlacementStarted extends OrderPlacementEvent {
  const OrderPlacementStarted({
    required this.fundId,
    this.exchange = TradeExchange.nse,
    this.side,
  });
  final String fundId;
  final TradeExchange exchange;
  final TradeSide? side;
}

final class OrderSideChanged extends OrderPlacementEvent {
  const OrderSideChanged(this.side);
  final OrderSide side;
}

final class OrderExchangeChanged extends OrderPlacementEvent {
  const OrderExchangeChanged(this.exchange);
  final TradeExchange exchange;
}

final class OrderQuantityIncremented extends OrderPlacementEvent {
  const OrderQuantityIncremented();
}

final class OrderQuantityDecremented extends OrderPlacementEvent {
  const OrderQuantityDecremented();
}

final class OrderQuantityChanged extends OrderPlacementEvent {
  const OrderQuantityChanged(this.value);
  final String value;
}

final class OrderTypeChanged extends OrderPlacementEvent {
  const OrderTypeChanged(this.orderType);
  final TradeOrderType orderType;
}

final class OrderLimitPriceChanged extends OrderPlacementEvent {
  const OrderLimitPriceChanged(this.value);
  final String value;
}

final class OrderTriggerPriceChanged extends OrderPlacementEvent {
  const OrderTriggerPriceChanged(this.value);
  final String value;
}

final class OrderProductChanged extends OrderPlacementEvent {
  const OrderProductChanged(this.product);
  final TradeProduct product;
}

final class OrderValidityChanged extends OrderPlacementEvent {
  const OrderValidityChanged(this.validity);
  final OrderValidity validity;
}

final class OrderReviewRequested extends OrderPlacementEvent {
  const OrderReviewRequested();
}

final class OrderReviewCancelled extends OrderPlacementEvent {
  const OrderReviewCancelled();
}

final class OrderPlacementConfirmed extends OrderPlacementEvent {
  const OrderPlacementConfirmed();
}

final class OrderPlacementRetryRequested extends OrderPlacementEvent {
  const OrderPlacementRetryRequested();
}

final class OrderFundsAddedAndRetryRequested extends OrderPlacementEvent {
  const OrderFundsAddedAndRetryRequested(this.amount);
  final double amount;
}

final class OrderSellAvailableRequested extends OrderPlacementEvent {
  const OrderSellAvailableRequested();
}

final class OrderLivePricesReceived extends OrderPlacementEvent {
  const OrderLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}

final class OrderPositionAvailabilityChanged extends OrderPlacementEvent {
  const OrderPositionAvailabilityChanged();
}
