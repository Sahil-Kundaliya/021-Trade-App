import 'dart:async';

import 'package:injectable/injectable.dart';

import '../api/orderbook_local_api.dart';
import '../models/order_dto.dart';
import '../../notifications/trading_order_event.dart';
import 'order_book_change.dart';

typedef OrderMutation = List<OrderDto> Function(List<OrderDto> current);

/// The single in-process view of the persisted order book.
///
/// All writes are serialized here so placement, cancellation, and execution
/// cannot overwrite one another with stale read/modify/write snapshots.
@lazySingleton
class OrderStore {
  OrderStore(this._localApi);

  final OrderBookLocalApi _localApi;
  final StreamController<OrderBookChange> _changes =
      StreamController<OrderBookChange>.broadcast(sync: true);
  final StreamController<TradingOrderEvent> _events =
      StreamController<TradingOrderEvent>.broadcast(sync: true);
  Future<void> _operations = Future<void>.value();
  Future<void>? _initialization;
  bool _initialized = false;
  List<OrderDto> _orders = const [];

  Stream<OrderBookChange> get changes => _changes.stream;
  Stream<TradingOrderEvent> get events => _events.stream;
  List<OrderDto> get current => _orders;

  Future<List<OrderDto>> getOrders() async {
    await initialize();
    return _orders;
  }

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _load();
      _initialized = true;
    } finally {
      _initialization = null;
    }
  }

  Future<void> _load() async {
    _orders = List<OrderDto>.unmodifiable(await _localApi.getOrders());
  }

  Future<List<OrderDto>> mutate(OrderMutation mutation) {
    final result = _operations.then((_) async {
      await initialize();
      final previous = _orders;
      final next = List<OrderDto>.unmodifiable(mutation(_orders));
      _validate(next);
      await _localApi.saveOrders(next);
      _orders = next;
      final events = _deriveEvents(previous, next);
      _changes.add(OrderBookChange(next, events));
      for (final event in events) {
        _events.add(event);
      }
      return next;
    });
    _operations = result.then<void>((_) {}, onError: (_, stackTrace) {});
    return result;
  }

  Future<void> append(OrderDto order) async {
    await mutate((orders) => <OrderDto>[...orders, order]);
  }

  Future<bool> replace(OrderDto order) async {
    var replaced = false;
    await mutate((orders) {
      final next = orders
          .map((existing) {
            if (existing.id != order.id) return existing;
            replaced = true;
            return order;
          })
          .toList(growable: false);
      return replaced ? next : orders;
    });
    return replaced;
  }

  Future<bool> cancel(String orderId) async {
    var cancelled = false;
    await mutate((orders) {
      return orders
          .map((order) {
            if (order.id != orderId ||
                const {
                  'executed',
                  'cancelled',
                  'rejected',
                }.contains(order.status)) {
              return order;
            }
            cancelled = true;
            return order.copyWith(
              status: 'cancelled',
              updatedAt: DateTime.now(),
            );
          })
          .toList(growable: false);
    });
    return cancelled;
  }

  static void _validate(List<OrderDto> orders) {
    final ids = orders.map((order) => order.id).toSet();
    if (ids.length != orders.length) {
      throw StateError('Order IDs must be unique.');
    }
  }

  static List<TradingOrderEvent> _deriveEvents(
    List<OrderDto> previous,
    List<OrderDto> next,
  ) {
    final oldById = <String, OrderDto>{
      for (final order in previous) order.id: order,
    };
    final events = <TradingOrderEvent>[];
    for (final order in next) {
      final old = oldById[order.id];
      if (old == null) {
        events.add(
          TradingOrderEvent(
            type: order.status == 'executed'
                ? TradingOrderEventType.executed
                : order.status == 'rejected'
                ? TradingOrderEventType.rejected
                : TradingOrderEventType.placed,
            order: order,
          ),
        );
      } else if (old.status != order.status) {
        final type = switch (order.status) {
          'open' when old.status == 'triggerPending' =>
            TradingOrderEventType.triggered,
          'executed' => TradingOrderEventType.executed,
          'cancelled' => TradingOrderEventType.cancelled,
          'rejected' => TradingOrderEventType.rejected,
          _ => null,
        };
        if (type != null) {
          events.add(TradingOrderEvent(type: type, order: order));
        }
      }
    }
    return List.unmodifiable(events);
  }
}
