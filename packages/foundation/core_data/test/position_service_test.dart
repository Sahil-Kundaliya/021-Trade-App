import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PositionService', () {
    test('derives weighted average, partial sell, and full removal', () async {
      final api = _MemoryOrderApi();
      final store = OrderStore(api);
      final service = PositionServiceImpl(store, _EmptyTradingApi());

      await store.append(
        _order('buy-1', side: 'buy', quantity: 10, price: 100, day: 1),
      );
      await store.append(
        _order('buy-2', side: 'buy', quantity: 10, price: 120, day: 2),
      );
      await store.append(
        _order('sell-1', side: 'sell', quantity: 5, price: 130, day: 3),
      );

      final position = (await service.getPositions()).single;
      expect(position.quantity, 15);
      expect(position.averageCost, 110);

      await store.append(
        _order('sell-2', side: 'sell', quantity: 15, price: 125, day: 4),
      );
      expect(await service.getPositions(), isEmpty);
    });

    test('keeps exchanges and derivative contracts isolated', () async {
      final store = OrderStore(_MemoryOrderApi());
      final service = PositionServiceImpl(store, _EmptyTradingApi());
      await store.append(_order('nse', fundId: 'same', exchange: 'nse'));
      await store.append(_order('bse', fundId: 'same', exchange: 'bse'));
      await store.append(_order('future', fundId: 'contract_aug'));

      final positions = await service.getPositions();
      expect(positions, hasLength(3));
      expect(positions.map((item) => item.marketKey).toSet(), hasLength(3));
    });

    test('reserves only pending quantities on active sell orders', () async {
      final store = OrderStore(_MemoryOrderApi());
      final service = PositionServiceImpl(store, _EmptyTradingApi());
      await store.append(_order('buy', quantity: 10));
      await store.append(
        _order(
          'open-sell',
          side: 'sell',
          status: 'partiallyFilled',
          quantity: 6,
          filledQuantity: 2,
          pendingQuantity: 4,
        ),
      );

      expect(
        await service.getAvailableSellQuantity(
          fundId: 'fund',
          exchange: TradeExchange.nse,
        ),
        6,
      );
      await store.cancel('open-sell');
      expect(
        await service.getAvailableSellQuantity(
          fundId: 'fund',
          exchange: TradeExchange.nse,
        ),
        10,
      );
    });

    test(
      'rejects corrupt executed history instead of going negative',
      () async {
        final store = OrderStore(_MemoryOrderApi());
        final service = PositionServiceImpl(store, _EmptyTradingApi());
        await store.append(_order('sell', side: 'sell'));

        await expectLater(
          service.getPositions(),
          throwsA(isA<PositionDataException>()),
        );
      },
    );
  });
}

OrderDto _order(
  String id, {
  String fundId = 'fund',
  String exchange = 'nse',
  String side = 'buy',
  String status = 'executed',
  int quantity = 10,
  int? filledQuantity,
  int? pendingQuantity,
  double price = 100,
  int day = 1,
}) => OrderDto(
  id: id,
  fundId: fundId,
  symbol: fundId,
  companyName: fundId,
  exchange: exchange,
  instrumentType: 'equity',
  side: side,
  orderType: 'market',
  productType: 'delivery',
  status: status,
  quantity: quantity,
  filledQuantity: filledQuantity ?? (status == 'executed' ? quantity : 0),
  pendingQuantity: pendingQuantity ?? (status == 'executed' ? 0 : quantity),
  ltp: price,
  averagePrice: status == 'executed' ? price : null,
  orderValue: quantity * price,
  validity: 'DAY',
  createdAt: DateTime(2026, 1, day),
  updatedAt: DateTime(2026, 1, day),
);

final class _MemoryOrderApi implements OrderBookLocalApi {
  List<OrderDto> orders = const [];

  @override
  Future<List<OrderDto>> getOrders() async => orders;

  @override
  Future<void> saveOrders(List<OrderDto> orders) async =>
      this.orders = List.unmodifiable(orders);
}

final class _EmptyTradingApi implements TradingLocalApi {
  @override
  Future<List<FundDto>> getFunds() async => const [];
  @override
  Future<List<HoldingDto>> getHoldings() async => const [];
  @override
  Future<List<MarketIndexDto>> getMarketIndices() async => const [];
}
