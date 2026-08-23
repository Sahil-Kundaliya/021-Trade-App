import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../live_price/models/live_instrument_seed.dart';
import '../live_price/models/live_price_batch.dart';
import '../live_price/stream/live_price_lease.dart';
import '../live_price/stream/live_price_stream_manager.dart';
import '../market/market_instrument_key.dart';
import '../market/trade_exchange.dart';
import '../orderbook/models/order_dto.dart';
import '../orderbook/store/order_book_change.dart';
import '../orderbook/store/order_store.dart';
import '../positions/exceptions/position_exception.dart';
import '../positions/position_service.dart';
import '../trading/api/trading_local_api.dart';
import '../trading/models/fund_dto.dart';

@lazySingleton
class OrderExecutionEngine {
  OrderExecutionEngine(
    this._orders,
    this._prices,
    this._tradingApi,
    this._positions,
  );

  final OrderStore _orders;
  final LivePriceStreamManager _prices;
  final TradingLocalApi _tradingApi;
  final PositionService _positions;
  final Set<String> _processingOrderIds = <String>{};
  Map<String, FundDto> _funds = const {};
  StreamSubscription<OrderBookChange>? _orderSubscription;
  StreamSubscription<LivePriceBatch>? _priceSubscription;
  LivePriceLease? _lease;
  Future<void> _operations = Future<void>.value();
  Future<void>? _starting;

  bool get isStarted => _starting != null;
  Set<String> get activeInstrumentIds =>
      _activeOrders().map((order) => order.fundId).toSet();
  Set<String> get _activeMarketKeys => _activeOrders()
      .map((order) => _marketKey(order.fundId, order.exchange))
      .toSet();

  Future<void> start() => _starting ??= _start();

  Future<void> _start() async {
    final results = await Future.wait<dynamic>([
      _orders.initialize(),
      _tradingApi.getFunds(),
    ]);
    final funds = results[1] as List<FundDto>;
    _funds = <String, FundDto>{for (final fund in funds) fund.id: fund};
    _orderSubscription = _orders.changes.listen(_onOrdersChanged);
    await _synchronizeLease();
    await _evaluateLatest();
  }

  void _onOrdersChanged(OrderBookChange change) {
    _enqueue(() async {
      await _synchronizeLease();
      await _evaluateLatest();
    });
  }

  void _onPrices(LivePriceBatch batch) {
    _enqueue(() async {
      for (final tick in batch.updates) {
        await _evaluateInstrument(tick.instrumentId, tick.ltp);
      }
    });
  }

  Future<void> _synchronizeLease() async {
    final seeds = <LiveInstrumentSeed>[];
    for (final marketKey in _activeMarketKeys) {
      final order = _activeOrders().firstWhere(
        (item) => _marketKey(item.fundId, item.exchange) == marketKey,
      );
      final fund = _funds[order.fundId];
      if (fund == null) continue;
      final exchange = TradeExchange.parse(order.exchange);
      final listing = fund.listingFor(exchange);
      if (listing == null) continue;
      seeds.add(
        LiveInstrumentSeed.fromPrices(
          marketKey: marketKey,
          fundId: fund.id,
          exchange: exchange,
          assetType: switch (fund.instrumentType) {
            'FUTURE' => LiveMarketAssetType.future,
            'OPTION' => LiveMarketAssetType.option,
            _ => LiveMarketAssetType.equity,
          },
          symbol: fund.symbol,
          ltp: listing.ltp,
          previousClose: listing.previousClose,
          tickSize: listing.tickSize,
        ),
      );
    }
    final lease = _lease;
    if (lease == null) {
      if (seeds.isEmpty) return;
      final acquired = _prices.acquire(instruments: seeds);
      _lease = acquired;
      _priceSubscription = acquired.stream.listen(_onPrices);
    } else {
      await lease.update(seeds);
    }
  }

  Future<void> _evaluateLatest() async {
    for (final marketKey in _activeMarketKeys) {
      final tick = _prices.latestFor(marketKey);
      if (tick != null) await _evaluateInstrument(marketKey, tick.ltp);
    }
  }

  Future<void> _evaluateInstrument(String marketKey, double ltp) async {
    final ids = _activeOrders()
        .where((order) => _marketKey(order.fundId, order.exchange) == marketKey)
        .map((order) => order.id)
        .toList(growable: false);
    for (final id in ids) {
      await _evaluateOrder(id, ltp);
    }
  }

  Future<void> _evaluateOrder(String orderId, double ltp) async {
    if (!_processingOrderIds.add(orderId)) return;
    try {
      var order = _orders.current
          .where((item) => item.id == orderId)
          .firstOrNull;
      if (order == null || !_isActive(order.status)) return;
      if (order.orderType == 'stopLoss' && order.status == 'triggerPending') {
        if (!_triggerReached(order, ltp)) return;
        order = order.copyWith(status: 'open', updatedAt: DateTime.now());
        await _orders.replace(order);
        _log('triggered ${order.side} SL ${order.id} at $ltp');
      } else if (order.orderType == 'stopLossMarket') {
        if (!_triggerReached(order, ltp)) return;
        await _execute(order, ltp);
        return;
      }

      if ((order.orderType == 'limit' || order.orderType == 'stopLoss') &&
          _limitReached(order, ltp)) {
        await _execute(order, ltp);
      }
    } finally {
      _processingOrderIds.remove(orderId);
    }
  }

  bool _triggerReached(OrderDto order, double ltp) {
    final trigger = order.triggerPrice;
    if (trigger == null) return false;
    return order.side == 'buy' ? ltp >= trigger : ltp <= trigger;
  }

  bool _limitReached(OrderDto order, double ltp) {
    final limit = order.limitPrice;
    if (limit == null) return false;
    return order.side == 'buy' ? ltp <= limit : ltp >= limit;
  }

  Future<void> _execute(OrderDto order, double ltp) async {
    var outcome = '';
    await _orders.mutate((orders) {
      final current = orders.where((item) => item.id == order.id).firstOrNull;
      if (current == null || !_isActive(current.status)) return orders;
      var replacement = current.copyWith(
        status: 'executed',
        filledQuantity: current.quantity,
        pendingQuantity: 0,
        averagePrice: ltp,
        orderValue: current.quantity * ltp,
        updatedAt: DateTime.now(),
      );
      if (current.side == 'sell') {
        try {
          final owned = _positions.ownedQuantityFromOrders(
            orders,
            fundId: current.fundId,
            exchange: TradeExchange.parse(current.exchange),
          );
          if (current.quantity > owned) {
            replacement = current.copyWith(
              status: 'rejected',
              rejectionReason: 'Insufficient holding quantity.',
              updatedAt: DateTime.now(),
            );
            outcome = 'REJECTED: insufficient holding quantity';
          }
        } on PositionDataException {
          replacement = current.copyWith(
            status: 'rejected',
            rejectionReason: 'Insufficient holding quantity.',
            updatedAt: DateTime.now(),
          );
          outcome = 'REJECTED: inconsistent position history';
        }
      }
      outcome = outcome.isEmpty ? 'EXECUTED at $ltp' : outcome;
      return orders
          .map((item) => item.id == current.id ? replacement : item)
          .toList(growable: false);
    });
    if (outcome.isNotEmpty) {
      _log('${order.side} ${order.orderType} ${order.id}: $outcome');
    }
  }

  List<OrderDto> _activeOrders() => _orders.current
      .where((order) => _isActive(order.status))
      .toList(growable: false);

  static bool _isActive(String status) => const <String>{
    'open',
    'pending',
    'triggerPending',
    'partiallyFilled',
  }.contains(status);

  static String _marketKey(String fundId, String exchange) =>
      MarketInstrumentKey(
        fundId: fundId,
        exchange: TradeExchange.parse(exchange),
      ).value;

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _operations.then((_) => operation());
    _operations = result.catchError((Object _, StackTrace stackTrace) {});
    return result;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[Execution] $message');
  }

  @visibleForTesting
  Future<void> evaluatePrice(String instrumentId, double ltp) {
    final marketKey = instrumentId.contains(':')
        ? instrumentId
        : MarketInstrumentKey(
            fundId: instrumentId,
            exchange: TradeExchange.nse,
          ).value;
    return _enqueue(() => _evaluateInstrument(marketKey, ltp));
  }

  @visibleForTesting
  Future<void> stop() async {
    await _orderSubscription?.cancel();
    await _priceSubscription?.cancel();
    await _lease?.dispose();
    _orderSubscription = null;
    _priceSubscription = null;
    _lease = null;
  }
}
