import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OrderExecutionEngine', () {
    test('buy and sell limits execute at exact or crossed prices', () async {
      final fixture = _Fixture();
      await fixture.add(_order(id: 'buy', side: 'buy', limit: 100));
      await fixture.add(_order(id: 'sell', side: 'sell', limit: 105));

      await fixture.engine.evaluatePrice('fund', 101);
      expect(fixture.order('buy').status, 'open');
      await fixture.engine.evaluatePrice('fund', 99.95);
      expect(fixture.order('buy').status, 'executed');
      expect(fixture.order('buy').averagePrice, 99.95);

      await fixture.engine.evaluatePrice('fund', 106);
      expect(fixture.order('sell').status, 'executed');
      expect(fixture.order('sell').averagePrice, 106);
    });

    test('buy and sell SL-M trigger in the correct direction', () async {
      final fixture = _Fixture();
      await fixture.add(
        _order(
          id: 'buy-slm',
          side: 'buy',
          type: 'stopLossMarket',
          status: 'triggerPending',
          trigger: 110,
        ),
      );
      await fixture.add(
        _order(
          id: 'sell-slm',
          side: 'sell',
          type: 'stopLossMarket',
          status: 'triggerPending',
          trigger: 90,
        ),
      );

      await fixture.engine.evaluatePrice('fund', 109);
      expect(fixture.order('buy-slm').status, 'triggerPending');
      await fixture.engine.evaluatePrice('fund', 110);
      expect(fixture.order('buy-slm').status, 'executed');

      await fixture.engine.evaluatePrice('fund', 91);
      expect(fixture.order('sell-slm').status, 'triggerPending');
      await fixture.engine.evaluatePrice('fund', 90);
      expect(fixture.order('sell-slm').status, 'executed');
    });

    test('SL persists trigger then fills on a later price', () async {
      final fixture = _Fixture();
      await fixture.add(
        _order(
          id: 'sl',
          side: 'sell',
          type: 'stopLoss',
          status: 'triggerPending',
          trigger: 90,
          limit: 92,
        ),
      );

      await fixture.engine.evaluatePrice('fund', 90);
      expect(fixture.order('sl').status, 'open');
      await fixture.engine.evaluatePrice('fund', 92);
      expect(fixture.order('sl').status, 'executed');
    });

    test('SL can trigger and fill on the same flat tick', () async {
      final fixture = _Fixture();
      await fixture.add(
        _order(
          id: 'same-tick',
          side: 'buy',
          type: 'stopLoss',
          status: 'triggerPending',
          trigger: 100,
          limit: 100,
        ),
      );

      await fixture.engine.evaluatePrice('fund', 100);
      expect(fixture.order('same-tick').status, 'executed');
      expect(fixture.api.saveCount, 3); // placement, trigger, execution
    });

    test('rapid duplicate ticks execute exactly once', () async {
      final fixture = _Fixture();
      await fixture.add(_order(id: 'race', side: 'buy', limit: 100));

      await Future.wait([
        fixture.engine.evaluatePrice('fund', 100),
        fixture.engine.evaluatePrice('fund', 99),
      ]);

      expect(fixture.order('race').status, 'executed');
      expect(fixture.api.saveCount, 2); // placement plus one execution
    });

    test('terminal and cancelled orders never execute or reopen', () async {
      final fixture = _Fixture();
      await fixture.add(
        _order(id: 'cancelled', side: 'buy', status: 'cancelled', limit: 100),
      );
      await fixture.add(
        _order(id: 'executed', side: 'buy', status: 'executed', limit: 100),
      );
      final writes = fixture.api.saveCount;

      await fixture.engine.evaluatePrice('fund', 90);

      expect(fixture.order('cancelled').status, 'cancelled');
      expect(fixture.order('executed').status, 'executed');
      expect(fixture.api.saveCount, writes);
    });

    test(
      'NSE and BSE orders execute only from their own listing price',
      () async {
        final fixture = _Fixture();
        await fixture.add(
          _order(id: 'nse-order', side: 'buy', exchange: 'nse', limit: 1300),
        );
        await fixture.add(
          _order(id: 'bse-order', side: 'buy', exchange: 'bse', limit: 1300),
        );

        await fixture.engine.evaluatePrice('fund:NSE', 1299.95);

        expect(fixture.order('nse-order').status, 'executed');
        expect(fixture.order('bse-order').status, 'open');

        await fixture.engine.evaluatePrice('fund:BSE', 1299.90);
        expect(fixture.order('bse-order').status, 'executed');
      },
    );
  });
}

final class _Fixture {
  _Fixture() : api = _MemoryOrderApi(), platform = _FakePricePlatform() {
    store = OrderStore(api);
    engine = OrderExecutionEngine(
      store,
      LivePriceStreamManager(platform),
      _EmptyTradingApi(),
    );
  }

  final _MemoryOrderApi api;
  final _FakePricePlatform platform;
  late final OrderStore store;
  late final OrderExecutionEngine engine;

  Future<void> add(OrderDto order) => store.append(order);

  OrderDto order(String id) =>
      store.current.singleWhere((order) => order.id == id);
}

OrderDto _order({
  required String id,
  required String side,
  String type = 'limit',
  String status = 'open',
  double? limit,
  double? trigger,
  String exchange = 'nse',
}) => OrderDto(
  id: id,
  fundId: 'fund',
  symbol: 'TEST',
  companyName: 'Test Limited',
  exchange: exchange,
  instrumentType: 'equity',
  side: side,
  orderType: type,
  productType: 'delivery',
  status: status,
  quantity: 10,
  filledQuantity: status == 'executed' ? 10 : 0,
  pendingQuantity: status == 'executed' ? 0 : 10,
  ltp: 101,
  averagePrice: status == 'executed' ? 101 : null,
  limitPrice: limit,
  triggerPrice: trigger,
  orderValue: 1010,
  validity: 'DAY',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final class _MemoryOrderApi implements OrderBookLocalApi {
  List<OrderDto> orders = const [];
  int saveCount = 0;

  @override
  Future<List<OrderDto>> getOrders() async => orders;

  @override
  Future<void> saveOrders(List<OrderDto> orders) async {
    await Future<void>.delayed(Duration.zero);
    saveCount++;
    this.orders = List<OrderDto>.unmodifiable(orders);
  }
}

final class _EmptyTradingApi implements TradingLocalApi {
  @override
  Future<List<FundDto>> getFunds() async => const [];

  @override
  Future<List<HoldingDto>> getHoldings() async => const [];

  @override
  Future<List<MarketIndexDto>> getMarketIndices() async => const [];
}

final class _FakePricePlatform implements LivePricePlatformApi {
  final _batches = StreamController<Object?>.broadcast();

  @override
  Stream<Object?> get batches => _batches.stream;

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {}

  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {}
}
