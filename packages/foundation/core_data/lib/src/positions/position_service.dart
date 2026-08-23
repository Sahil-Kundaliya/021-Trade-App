import 'dart:async';

import 'package:injectable/injectable.dart';

import '../market/market_instrument_key.dart';
import '../market/trade_exchange.dart';
import '../orderbook/models/order_dto.dart';
import '../orderbook/store/order_store.dart';
import '../trading/api/trading_local_api.dart';
import '../trading/models/fund_dto.dart';
import 'exceptions/position_exception.dart';
import 'models/derived_position.dart';

abstract interface class PositionService {
  Future<List<DerivedPosition>> getPositions();

  Future<DerivedPosition?> getPosition({
    required String fundId,
    required TradeExchange exchange,
  });

  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  });

  Stream<List<DerivedPosition>> get positionChanges;

  int ownedQuantityFromOrders(
    List<OrderDto> orders, {
    required String fundId,
    required TradeExchange exchange,
  });

  int availableSellQuantityFromOrders(
    List<OrderDto> orders, {
    required String fundId,
    required TradeExchange exchange,
  });
}

@LazySingleton(as: PositionService)
final class PositionServiceImpl implements PositionService {
  PositionServiceImpl(this._orders, this._tradingApi) {
    _orders.changes.listen((_) => _publish());
  }

  final OrderStore _orders;
  final TradingLocalApi _tradingApi;
  final StreamController<List<DerivedPosition>> _changes =
      StreamController<List<DerivedPosition>>.broadcast();
  Future<Map<String, FundDto>>? _funds;
  Future<void> _publishing = Future<void>.value();

  @override
  Stream<List<DerivedPosition>> get positionChanges => _changes.stream;

  Future<Map<String, FundDto>> _getFunds() =>
      _funds ??= _tradingApi.getFunds().then(
        (funds) => <String, FundDto>{for (final fund in funds) fund.id: fund},
      );

  void _publish() {
    _publishing = _publishing.then((_) async {
      try {
        _changes.add(await getPositions());
      } on Object catch (error, stackTrace) {
        _changes.addError(error, stackTrace);
      }
    });
  }

  @override
  Future<List<DerivedPosition>> getPositions() async {
    final results = await Future.wait<dynamic>([
      _orders.getOrders(),
      _getFunds(),
    ]);
    return _derive(
      results[0] as List<OrderDto>,
      results[1] as Map<String, FundDto>,
    );
  }

  @override
  Future<DerivedPosition?> getPosition({
    required String fundId,
    required TradeExchange exchange,
  }) async {
    final key = MarketInstrumentKey(fundId: fundId, exchange: exchange).value;
    return (await getPositions())
        .where((item) => item.marketKey == key)
        .firstOrNull;
  }

  @override
  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  }) async => availableSellQuantityFromOrders(
    await _orders.getOrders(),
    fundId: fundId,
    exchange: exchange,
  );

  @override
  int ownedQuantityFromOrders(
    List<OrderDto> orders, {
    required String fundId,
    required TradeExchange exchange,
  }) {
    var quantity = 0;
    final matching =
        orders
            .where(
              (order) =>
                  _isExecuted(order.status) &&
                  order.fundId == fundId &&
                  TradeExchange.parse(order.exchange) == exchange,
            )
            .toList()
          ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    for (final order in matching) {
      final filled = order.filledQuantity > 0
          ? order.filledQuantity
          : order.quantity;
      quantity += _isSell(order.side) ? -filled : filled;
      if (quantity < 0) {
        throw PositionDataException(
          'Executed order history oversells ${order.fundId}:${exchange.code}.',
        );
      }
    }
    return quantity;
  }

  @override
  int availableSellQuantityFromOrders(
    List<OrderDto> orders, {
    required String fundId,
    required TradeExchange exchange,
  }) {
    final owned = ownedQuantityFromOrders(
      orders,
      fundId: fundId,
      exchange: exchange,
    );
    final reserved = orders
        .where(
          (order) =>
              _isSell(order.side) &&
              _isReservable(order.status) &&
              order.fundId == fundId &&
              TradeExchange.parse(order.exchange) == exchange,
        )
        .fold<int>(0, (total, order) => total + order.pendingQuantity);
    return (owned - reserved).clamp(0, owned);
  }

  List<DerivedPosition> _derive(
    List<OrderDto> orders,
    Map<String, FundDto> funds,
  ) {
    final positions = <String, _PositionAccumulator>{};
    final executed = orders.where((order) => _isExecuted(order.status)).toList()
      ..sort((a, b) {
        final timestamp = a.updatedAt.compareTo(b.updatedAt);
        return timestamp != 0 ? timestamp : a.createdAt.compareTo(b.createdAt);
      });
    for (final order in executed) {
      final exchange = TradeExchange.parse(order.exchange);
      final key = MarketInstrumentKey(
        fundId: order.fundId,
        exchange: exchange,
      ).value;
      final quantity = order.filledQuantity > 0
          ? order.filledQuantity
          : order.quantity;
      if (quantity <= 0) continue;
      final current = positions[key];
      if (_isSell(order.side)) {
        if (current == null || quantity > current.quantity) {
          throw PositionDataException('Executed order history oversells $key.');
        }
        current.quantity -= quantity;
        current.updatedAt = order.updatedAt;
        if (current.quantity == 0) positions.remove(key);
        continue;
      }
      final price = order.averagePrice ?? order.ltp;
      if (current == null) {
        positions[key] = _PositionAccumulator(
          order: order,
          exchange: exchange,
          quantity: quantity,
          averageCost: price,
        );
      } else {
        final nextQuantity = current.quantity + quantity;
        current.averageCost =
            ((current.quantity * current.averageCost) + (quantity * price)) /
            nextQuantity;
        current.quantity = nextQuantity;
        current.updatedAt = order.updatedAt;
      }
    }
    return List<DerivedPosition>.unmodifiable(
      positions.values.map((value) {
        final fund = funds[value.order.fundId];
        final listing = fund?.listingFor(value.exchange);
        final instrumentType =
            fund?.instrumentType ?? value.order.instrumentType;
        return DerivedPosition(
          fundId: value.order.fundId,
          exchange: value.exchange,
          symbol: fund?.symbol ?? value.order.symbol,
          companyName: fund?.companyName ?? value.order.companyName,
          instrumentType: instrumentType,
          category: _category(instrumentType),
          quantity: value.quantity,
          averageCost: value.averageCost,
          lotSize: fund?.lotSize ?? 1,
          openedAt: value.openedAt,
          updatedAt: value.updatedAt,
          staticLtp: listing?.ltp ?? fund?.ltp ?? value.order.ltp,
          previousClose:
              listing?.previousClose ?? fund?.previousClose ?? value.order.ltp,
          tickSize: listing?.tickSize ?? fund?.tickSize ?? .05,
        );
      }),
    );
  }

  static bool _isExecuted(String value) => value.toLowerCase() == 'executed';
  static bool _isSell(String value) => value.toLowerCase() == 'sell';
  static bool _isReservable(String value) => const {
    'open',
    'pending',
    'triggerpending',
    'partiallyfilled',
  }.contains(value.replaceAll('_', '').toLowerCase());

  static PortfolioCategory _category(String value) =>
      switch (value.toUpperCase()) {
        'FUTURE' => PortfolioCategory.future,
        'OPTION' || 'OPTIONS' => PortfolioCategory.options,
        _ => PortfolioCategory.equity,
      };
}

final class _PositionAccumulator {
  _PositionAccumulator({
    required this.order,
    required this.exchange,
    required this.quantity,
    required this.averageCost,
  }) : openedAt = order.updatedAt,
       updatedAt = order.updatedAt;

  final OrderDto order;
  final TradeExchange exchange;
  int quantity;
  double averageCost;
  final DateTime openedAt;
  DateTime updatedAt;
}
