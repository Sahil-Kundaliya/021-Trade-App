import '../../domain/entities/trade_order.dart';

abstract final class OrderFormat {
  static String currency(double value) => '₹${number(value)}';

  static String number(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts.first;
    if (whole.length <= 3) return '$whole.${parts.last}';
    final lastThree = whole.substring(whole.length - 3);
    final leading = whole.substring(0, whole.length - 3);
    final grouped = leading.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (_) => ',',
    );
    return '$grouped,$lastThree.${parts.last}';
  }

  static String time(DateTime value, {bool includeSeconds = false}) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final seconds = value.second.toString().padLeft(2, '0');
    final period = value.hour < 12 ? 'AM' : 'PM';
    return includeSeconds
        ? '$hour:$minute:$seconds $period'
        : '$hour:$minute $period';
  }

  static String side(OrderSide value) =>
      value == OrderSide.buy ? 'BUY' : 'SELL';
  static String exchange(TradeExchange value) =>
      value == TradeExchange.nse ? 'NSE' : 'BSE';
  static String status(OrderStatus value) => switch (value) {
    OrderStatus.open => 'OPEN',
    OrderStatus.pending => 'PENDING',
    OrderStatus.triggerPending => 'TRIGGER PENDING',
    OrderStatus.partiallyFilled => 'PARTIALLY FILLED',
    OrderStatus.executed => 'EXECUTED',
    OrderStatus.cancelled => 'CANCELLED',
    OrderStatus.rejected => 'REJECTED',
  };
  static String orderType(TradeOrderType value) => switch (value) {
    TradeOrderType.market => 'Market',
    TradeOrderType.limit => 'Limit',
    TradeOrderType.stopLoss => 'SL',
    TradeOrderType.stopLossMarket => 'SL-M',
  };
  static String product(TradeProductType value) =>
      value == TradeProductType.delivery ? 'Delivery' : 'Intraday';
}
