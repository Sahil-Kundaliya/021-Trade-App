import 'package:core_data/core_data.dart';
import 'package:core_data/src/orderbook/api/orderbook_local_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing storage returns an empty list without writing', () async {
    final storage = _MemoryStorage();
    final api = OrderBookLocalApiImpl(storage);

    expect(await api.getOrders(), isEmpty);
    expect(storage.writeCount, 0);
  });

  test('saved orders persist across API instances', () async {
    final storage = _MemoryStorage();
    final first = OrderBookLocalApiImpl(storage);
    final orders = [_order('order_a'), _order('order_b')];

    await first.saveOrders(orders);
    final second = OrderBookLocalApiImpl(storage);
    final restored = await second.getOrders();

    expect(restored.map((order) => order.id), ['order_a', 'order_b']);
  });
}

final class _MemoryStorage implements KeyValueStorage {
  String? value;
  int writeCount = 0;

  @override
  Future<String?> getString(String key) async => value;
  @override
  Future<void> setString(String key, String value) async {
    this.value = value;
    writeCount++;
  }

  @override
  Future<void> clear() async => value = null;
  @override
  Future<void> remove(String key) async => value = null;
}

OrderDto _order(String id) => OrderDto(
  id: id,
  fundId: 'RELIANCE_EQ',
  symbol: 'RELIANCE',
  companyName: 'Reliance Industries',
  exchange: 'nse',
  instrumentType: 'Equity',
  side: 'buy',
  orderType: 'market',
  productType: 'delivery',
  status: 'executed',
  quantity: 1,
  filledQuantity: 1,
  pendingQuantity: 0,
  ltp: 100,
  validity: 'DAY',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
