import 'package:core_data/core_data.dart';

import '../../domain/entities/order_draft.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/enums/order_enums.dart';

abstract final class PlacedOrderMapper {
  static OrderDto toDto(PlacedOrder order) {
    final draft = order.draft;
    return OrderDto(
      id: order.id,
      fundId: draft.instrument.id,
      symbol: draft.instrument.symbol,
      companyName: draft.instrument.companyName,
      exchange: draft.exchange.name,
      instrumentType: draft.instrument.instrumentType.name,
      side: draft.side.name,
      orderType: draft.orderType.name,
      productType: draft.product.name,
      status: order.status.name,
      quantity: draft.quantity,
      filledQuantity: order.filledQuantity,
      pendingQuantity: order.pendingQuantity,
      ltp: draft.instrument.ltp,
      averagePrice: order.averagePrice,
      limitPrice: draft.limitPrice,
      triggerPrice: draft.triggerPrice,
      orderValue: order.orderValue,
      validity: draft.validity.name.toUpperCase(),
      createdAt: order.createdAt,
      updatedAt: order.createdAt,
    );
  }

  static PlacedOrder create({
    required String id,
    required OrderDraft draft,
    required DateTime createdAt,
  }) {
    final market = draft.orderType == TradeOrderType.market;
    final status = switch (draft.orderType) {
      TradeOrderType.market => PlacedOrderStatus.executed,
      TradeOrderType.limit => PlacedOrderStatus.open,
      TradeOrderType.stopLoss ||
      TradeOrderType.stopLossMarket => PlacedOrderStatus.triggerPending,
    };
    return PlacedOrder(
      id: id,
      draft: draft,
      status: status,
      filledQuantity: market ? draft.quantity : 0,
      pendingQuantity: market ? 0 : draft.quantity,
      averagePrice: market ? draft.instrument.ltp : null,
      orderValue: draft.estimatedOrderValue,
      createdAt: createdAt,
    );
  }
}
