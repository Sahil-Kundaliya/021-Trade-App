import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order_draft.dart';
import '../../domain/entities/order_instrument.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/exceptions/order_placement_exception.dart';
import '../../domain/repositories/order_placement_repository.dart';
import '../mappers/order_instrument_mapper.dart';
import '../mappers/placed_order_mapper.dart';

@LazySingleton(as: OrderPlacementRepository)
final class OrderPlacementRepositoryImpl implements OrderPlacementRepository {
  OrderPlacementRepositoryImpl(this._tradingLocalApi, this._orderStore);

  final TradingLocalApi _tradingLocalApi;
  final OrderStore _orderStore;
  static const _uuid = Uuid();

  @override
  Future<OrderInstrument> getInstrument(String fundId) async {
    final funds = await _tradingLocalApi.getFunds();
    for (final fund in funds) {
      if (fund.id == fundId) return OrderInstrumentMapper.toDomain(fund);
    }
    throw OrderInstrumentNotFoundException(fundId);
  }

  @override
  Future<PlacedOrder> placeOrder(OrderDraft draft) async {
    final placed = PlacedOrderMapper.create(
      id: 'order_${_uuid.v4()}',
      draft: draft,
      createdAt: DateTime.now(),
    );
    await _orderStore.append(PlacedOrderMapper.toDto(placed));
    return placed;
  }
}
