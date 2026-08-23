import 'package:core_data/core_data.dart' hide TradeExchange;

import '../../domain/entities/trade_order.dart';

abstract final class OrderMapper {
  static TradeOrder toDomain(OrderDto dto) => TradeOrder(
    orderId: dto.id,
    exchangeOrderId: dto.exchangeOrderId,
    fundId: dto.fundId,
    symbol: dto.symbol,
    companyName: dto.companyName,
    exchange: _enumByName(TradeExchange.values, dto.exchange),
    instrumentType: dto.instrumentType,
    side: _enumByName(OrderSide.values, dto.side),
    orderType: _enumByName(TradeOrderType.values, dto.orderType),
    productType: _enumByName(TradeProductType.values, dto.productType),
    status: _enumByName(OrderStatus.values, dto.status),
    quantity: dto.quantity,
    filledQuantity: dto.filledQuantity,
    pendingQuantity: dto.pendingQuantity,
    ltp: dto.ltp,
    averagePrice: dto.averagePrice,
    limitPrice: dto.limitPrice,
    triggerPrice: dto.triggerPrice,
    orderValue: dto.orderValue,
    validity: dto.validity,
    rejectionReason: dto.rejectionReason,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );

  static T _enumByName<T extends Enum>(List<T> values, String source) {
    final normalized = source
        .trim()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .toLowerCase();
    return values.firstWhere(
      (value) => value.name.toLowerCase() == normalized,
      orElse: () => throw FormatException('Unknown ${T.toString()}: $source'),
    );
  }
}
