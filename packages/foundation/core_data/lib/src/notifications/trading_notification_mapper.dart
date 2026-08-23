import 'local_notification_service.dart';
import 'trading_order_event.dart';

abstract final class TradingNotificationMapper {
  static TradingNotification map(
    TradingOrderEvent event, {
    required bool private,
  }) {
    final title = switch (event.type) {
      TradingOrderEventType.placed when event.order.orderType == 'stopLoss' =>
        'Stop-loss order placed',
      TradingOrderEventType.placed
          when event.order.orderType == 'stopLossMarket' =>
        'Stop-loss market order placed',
      TradingOrderEventType.placed => 'Order placed',
      TradingOrderEventType.triggered => 'Stop-loss triggered',
      TradingOrderEventType.executed
          when event.order.orderType == 'stopLoss' ||
              event.order.orderType == 'stopLossMarket' =>
        'Stop-loss order executed',
      TradingOrderEventType.executed => 'Order executed',
      TradingOrderEventType.cancelled => 'Order cancelled',
      TradingOrderEventType.rejected => 'Order rejected',
    };
    return TradingNotification(
      id: event.eventId.hashCode & 0x7fffffff,
      title: title,
      body: private ? _privateBody(event.type) : _body(event),
      payload: 'orderbook',
    );
  }

  static String _privateBody(TradingOrderEventType type) => switch (type) {
    TradingOrderEventType.placed => 'Your trading order has been placed.',
    TradingOrderEventType.triggered =>
      'Your stop-loss order has been triggered.',
    TradingOrderEventType.executed => 'Your trading order has been executed.',
    TradingOrderEventType.cancelled => 'Your trading order has been cancelled.',
    TradingOrderEventType.rejected => 'Your trading order was rejected.',
  };

  static String _body(TradingOrderEvent event) {
    final order = event.order;
    final side = order.side;
    return switch (event.type) {
      TradingOrderEventType.placed when order.orderType == 'limit' =>
        '${order.symbol} $side · ${order.quantity} Qty · Limit ${_money(order.limitPrice)}',
      TradingOrderEventType.placed =>
        '${order.symbol} $side · Trigger ${_money(order.triggerPrice)}',
      TradingOrderEventType.triggered =>
        '${order.symbol} $side order has been triggered.',
      TradingOrderEventType.executed =>
        '${order.symbol} $side · ${order.quantity} Qty at ${_money(order.averagePrice)}',
      TradingOrderEventType.cancelled =>
        '${order.symbol} $side order was cancelled.',
      TradingOrderEventType.rejected =>
        order.rejectionReason == null
            ? '${order.symbol} $side order was rejected.'
            : '${order.symbol} $side · ${order.rejectionReason}',
    };
  }

  static String _money(double? value) =>
      value == null ? 'market' : '₹${value.toStringAsFixed(2)}';
}
