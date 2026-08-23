import 'package:core_data/core_data.dart';
import 'package:core_data/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/order_placement/data/repositories/order_placement_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TradingLocalApi tradingApi;

  setUpAll(() {
    final getIt = GetIt.asNewInstance();
    registerCoreDataDependencies(getIt);
    tradingApi = getIt<TradingLocalApi>();
  });

  test(
    'repository loads equity, future, option and typed missing ID',
    () async {
      final repository = OrderPlacementRepositoryImpl(
        tradingApi,
        _MemoryOrderBookApi(),
      );
      expect(
        (await repository.getInstrument('RELIANCE_EQ')).instrumentType,
        OrderInstrumentType.equity,
      );
      expect(
        (await repository.getInstrument('TCS_FUT_20260825')).instrumentType,
        OrderInstrumentType.future,
      );
      expect(
        (await repository.getInstrument(
          'SBIN_OPT_1050_CE_20260825',
        )).instrumentType,
        OrderInstrumentType.option,
      );
      await expectLater(
        repository.getInstrument('MISSING'),
        throwsA(isA<OrderInstrumentNotFoundException>()),
      );
    },
  );

  test(
    'repository appends deterministic market, limit, SL and SL-M records',
    () async {
      final api = _MemoryOrderBookApi();
      final repository = OrderPlacementRepositoryImpl(tradingApi, api);
      final instrument = await repository.getInstrument('RELIANCE_EQ');

      Future<OrderDto> place(TradeOrderType type) async {
        final placed = await repository.placeOrder(
          OrderDraft(
            instrument: instrument,
            side: OrderSide.buy,
            exchange: TradeExchange.nse,
            quantity: 10,
            orderType: type,
            product: TradeProduct.delivery,
            validity: OrderValidity.day,
            limitPrice:
                type == TradeOrderType.limit || type == TradeOrderType.stopLoss
                ? instrument.ltp
                : null,
            triggerPrice:
                type == TradeOrderType.stopLoss ||
                    type == TradeOrderType.stopLossMarket
                ? instrument.ltp
                : null,
          ),
        );
        return api.orders.singleWhere((order) => order.id == placed.id);
      }

      final market = await place(TradeOrderType.market);
      expect(
        (
          market.status,
          market.filledQuantity,
          market.pendingQuantity,
          market.averagePrice,
        ),
        ('executed', 10, 0, instrument.ltp),
      );
      final limit = await place(TradeOrderType.limit);
      expect(
        (limit.status, limit.filledQuantity, limit.pendingQuantity),
        ('open', 0, 10),
      );
      final sl = await place(TradeOrderType.stopLoss);
      expect(
        (sl.status, sl.limitPrice, sl.triggerPrice),
        ('triggerPending', instrument.ltp, instrument.ltp),
      );
      final slm = await place(TradeOrderType.stopLossMarket);
      expect(
        (slm.status, slm.limitPrice, slm.triggerPrice),
        ('triggerPending', null, instrument.ltp),
      );
      expect(api.orders, hasLength(4));
      expect(api.orders.map((order) => order.id).toSet(), hasLength(4));
    },
  );

  test('bloc validates derivative lots and conditional price fields', () async {
    final repository = _BlocRepository(
      _instrument(type: OrderInstrumentType.option, lotSize: 750),
    );
    final bloc = OrderPlacementBloc(repository)
      ..add(const OrderPlacementStarted(fundId: 'option'));
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.ready,
    );

    bloc.add(const OrderQuantityChanged('751'));
    bloc.add(const OrderReviewRequested());
    await bloc.stream.firstWhere(
      (state) => state.fieldErrors.containsKey('quantity'),
    );
    expect(bloc.state.errorFor('quantity'), contains('750'));

    bloc.add(const OrderQuantityChanged('1500'));
    bloc.add(const OrderTypeChanged(TradeOrderType.limit));
    bloc.add(const OrderLimitPriceChanged(''));
    bloc.add(const OrderReviewRequested());
    await bloc.stream.firstWhere(
      (state) => state.fieldErrors.containsKey('limitPrice'),
    );
    expect(bloc.state.status, OrderPlacementStatus.ready);

    bloc.add(const OrderLimitPriceChanged('100'));
    bloc.add(const OrderReviewRequested());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.review,
    );
    await bloc.close();
  });

  test('two quick confirmations persist only once', () async {
    final repository = _BlocRepository(_instrument());
    final bloc = OrderPlacementBloc(
      repository,
    )..add(const OrderPlacementStarted(fundId: 'equity', side: TradeSide.sell));
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.ready,
    );
    bloc.add(const OrderReviewRequested());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.review,
    );
    bloc.add(const OrderPlacementConfirmed());
    bloc.add(const OrderPlacementConfirmed());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.success,
    );
    expect(repository.calls, 1);
    expect(repository.drafts.single.side, OrderSide.sell);
    await bloc.close();
  });
}

OrderInstrument _instrument({
  OrderInstrumentType type = OrderInstrumentType.equity,
  int lotSize = 1,
}) => OrderInstrument(
  id: 'fund',
  symbol: 'TEST',
  companyName: 'Test Limited',
  instrumentType: type,
  availableExchanges: type == OrderInstrumentType.equity
      ? TradeExchange.values
      : const [TradeExchange.nse],
  defaultExchange: TradeExchange.nse,
  ltp: 100,
  change: 1,
  changePercent: 1,
  lotSize: lotSize,
  tickSize: .05,
  allowedOrderTypes: TradeOrderType.values,
  allowedProducts: type == OrderInstrumentType.equity
      ? const [TradeProduct.delivery, TradeProduct.intraday]
      : const [TradeProduct.intraday, TradeProduct.overnight],
);

final class _MemoryOrderBookApi implements OrderBookLocalApi {
  List<OrderDto> orders = [];
  @override
  Future<List<OrderDto>> getOrders() async => List.unmodifiable(orders);
  @override
  Future<void> saveOrders(List<OrderDto> orders) async =>
      this.orders = List.unmodifiable(orders);
}

final class _BlocRepository implements OrderPlacementRepository {
  _BlocRepository(this.instrument);
  final OrderInstrument instrument;
  final drafts = <OrderDraft>[];
  int calls = 0;
  @override
  Future<OrderInstrument> getInstrument(String fundId) async => instrument;
  @override
  Future<PlacedOrder> placeOrder(OrderDraft draft) async {
    calls++;
    drafts.add(draft);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return PlacedOrder(
      id: 'order_test',
      draft: draft,
      status: PlacedOrderStatus.executed,
      filledQuantity: draft.quantity,
      pendingQuantity: 0,
      averagePrice: draft.instrument.ltp,
      orderValue: draft.estimatedOrderValue,
      createdAt: DateTime(2026),
    );
  }
}
