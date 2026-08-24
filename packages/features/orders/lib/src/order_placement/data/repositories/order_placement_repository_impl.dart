import 'dart:math' as math;

import 'package:core_data/core_data.dart' hide TradeExchange;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order_draft.dart';
import '../../domain/entities/order_instrument.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/enums/order_enums.dart';
import '../../domain/exceptions/order_placement_exception.dart';
import '../../domain/repositories/order_placement_repository.dart';
import '../mappers/order_instrument_mapper.dart';
import '../mappers/placed_order_mapper.dart';

@LazySingleton(as: OrderPlacementRepository)
final class OrderPlacementRepositoryImpl implements OrderPlacementRepository {
  OrderPlacementRepositoryImpl(
    this._tradingLocalApi,
    this._orderStore,
    this._positions,
    this._accountFundsLocalApi,
  );

  final TradingLocalApi _tradingLocalApi;
  final OrderStore _orderStore;
  final PositionService _positions;
  final AccountFundsLocalApi _accountFundsLocalApi;
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
  Stream<void> get positionChanges =>
      _positions.positionChanges.map<void>((_) {});

  @override
  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  }) => _positions.getAvailableSellQuantity(fundId: fundId, exchange: exchange);

  @override
  Future<double> getAvailableFunds() async =>
      (await _accountFundsLocalApi.read()).availableBalance;

  @override
  Future<double> addFunds(double amount) async {
    final bank = _accountFundsLocalApi.linkedBanks.firstWhere(
      (item) => item.isPrimary,
      orElse: () => _accountFundsLocalApi.linkedBanks.first,
    );
    var remainingPaise = (amount * 100).round();
    final credits = <Future<AccountFundsStorageDto>>[];
    while (remainingPaise > 0) {
      final partPaise = math.min(remainingPaise, 1000000);
      remainingPaise -= partPaise;
      credits.add(
        _accountFundsLocalApi.addFunds(
          depositId: 'deposit_${_uuid.v4()}',
          amount: partPaise / 100,
          bankId: bank.id,
        ),
      );
    }
    final updated = await Future.wait(credits);
    if (updated.isEmpty) {
      return getAvailableFunds();
    }
    return updated.last.availableBalance;
  }

  @override
  Future<PlacedOrder> placeOrder(OrderDraft draft) async {
    final placed = PlacedOrderMapper.create(
      id: 'order_${_uuid.v4()}',
      draft: draft,
      createdAt: DateTime.now(),
    );
    final dto = PlacedOrderMapper.toDto(placed);
    if (draft.side == OrderSide.buy) {
      await _accountFundsLocalApi.debitFunds(amount: placed.orderValue);
    }
    await _orderStore.mutate((orders) {
      if (draft.side == OrderSide.sell) {
        final available = _positions.availableSellQuantityFromOrders(
          orders,
          fundId: draft.instrument.id,
          exchange: draft.exchange,
        );
        if (draft.quantity > available) {
          throw InsufficientPositionException(
            availableQuantity: available,
            requestedQuantity: draft.quantity,
          );
        }
      }
      return <OrderDto>[...orders, dto];
    });
    return placed;
  }
}
