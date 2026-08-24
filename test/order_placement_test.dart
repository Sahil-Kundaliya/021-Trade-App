import 'dart:async';

import 'package:core_data/core_data.dart' hide TradeExchange;
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
      final store = OrderStore(_MemoryOrderBookApi());
      final repository = OrderPlacementRepositoryImpl(
        tradingApi,
        store,
        PositionServiceImpl(store, tradingApi),
        const _AccountFundsApi(),
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
      final store = OrderStore(api);
      final repository = OrderPlacementRepositoryImpl(
        tradingApi,
        store,
        PositionServiceImpl(store, tradingApi),
        const _AccountFundsApi(),
      );
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

  test('successful buy debits its order value from local funds', () async {
    final api = _MemoryOrderBookApi();
    final funds = _TrackingAccountFundsApi(5000);
    final store = OrderStore(api);
    final repository = OrderPlacementRepositoryImpl(
      tradingApi,
      store,
      PositionServiceImpl(store, tradingApi),
      funds,
    );
    final instrument = await repository.getInstrument('RELIANCE_EQ');
    final placed = await repository.placeOrder(
      OrderDraft(
        instrument: instrument,
        side: OrderSide.buy,
        exchange: TradeExchange.nse,
        quantity: 1,
        orderType: TradeOrderType.market,
        product: TradeProduct.delivery,
        validity: OrderValidity.day,
      ),
    );

    expect(funds.balance, 5000 - placed.orderValue);
    expect(api.orders, hasLength(1));
  });

  test('large order top-up is split and credited as one total', () async {
    final orderApi = _MemoryOrderBookApi();
    final funds = _TrackingAccountFundsApi(5000);
    final store = OrderStore(orderApi);
    final repository = OrderPlacementRepositoryImpl(
      tradingApi,
      store,
      PositionServiceImpl(store, tradingApi),
      funds,
    );

    final balance = await repository.addFunds(25500);

    expect(funds.addedAmounts, [10000, 10000, 5500]);
    expect(balance, 30500);
  });

  test(
    'sell placement validates ownership and active reservations atomically',
    () async {
      final api = _MemoryOrderBookApi();
      final store = OrderStore(api);
      final positions = PositionServiceImpl(store, tradingApi);
      final repository = OrderPlacementRepositoryImpl(
        tradingApi,
        store,
        positions,
        const _AccountFundsApi(),
      );
      final instrument = await repository.getInstrument('RELIANCE_EQ');
      OrderDraft draft({
        required OrderSide side,
        required int quantity,
        TradeOrderType type = TradeOrderType.market,
        TradeExchange exchange = TradeExchange.nse,
      }) => OrderDraft(
        instrument: instrument.forExchange(exchange),
        side: side,
        exchange: exchange,
        quantity: quantity,
        orderType: type,
        product: TradeProduct.delivery,
        validity: OrderValidity.day,
        limitPrice: type == TradeOrderType.limit ? instrument.ltp : null,
      );

      await expectLater(
        repository.placeOrder(draft(side: OrderSide.sell, quantity: 1)),
        throwsA(isA<InsufficientPositionException>()),
      );
      expect(api.orders, isEmpty);

      await repository.placeOrder(draft(side: OrderSide.buy, quantity: 10));
      final reserved = await repository.placeOrder(
        draft(side: OrderSide.sell, quantity: 6, type: TradeOrderType.limit),
      );
      expect(
        await repository.getAvailableSellQuantity(
          fundId: instrument.id,
          exchange: TradeExchange.nse,
        ),
        4,
      );
      await expectLater(
        repository.placeOrder(draft(side: OrderSide.sell, quantity: 5)),
        throwsA(isA<InsufficientPositionException>()),
      );
      expect(api.orders, hasLength(2));

      await store.cancel(reserved.id);
      expect(
        await repository.getAvailableSellQuantity(
          fundId: instrument.id,
          exchange: TradeExchange.nse,
        ),
        10,
      );
      await expectLater(
        repository.placeOrder(
          draft(side: OrderSide.sell, quantity: 1, exchange: TradeExchange.bse),
        ),
        throwsA(isA<InsufficientPositionException>()),
      );
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

  test('final confirmation checks buy funds and sell holdings', () async {
    final buyRepository = _BlocRepository(_instrument())..availableFunds = 50;
    final buyBloc = OrderPlacementBloc(buyRepository)
      ..add(const OrderPlacementStarted(fundId: 'equity'));
    await buyBloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.ready,
    );
    buyBloc.add(const OrderReviewRequested());
    await buyBloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.review,
    );
    expect(buyBloc.state.errorMessage, isNull);

    buyBloc.add(const OrderPlacementConfirmed());
    await buyBloc.stream.firstWhere((state) => state.errorMessage != null);
    expect(buyBloc.state.status, OrderPlacementStatus.failed);
    expect(buyBloc.state.errorMessage, contains('Insufficient funds'));
    expect(buyBloc.state.requiredFunds, 103);
    expect(buyRepository.calls, 0);
    await buyBloc.close();

    final sellRepository = _BlocRepository(_instrument())
      ..availableSellQuantity = 0;
    final sellBloc = OrderPlacementBloc(
      sellRepository,
    )..add(const OrderPlacementStarted(fundId: 'equity', side: TradeSide.sell));
    await sellBloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.ready,
    );
    sellBloc.add(const OrderReviewRequested());
    await sellBloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.review,
    );
    expect(sellBloc.state.errorMessage, isNull);

    sellBloc.add(const OrderPlacementConfirmed());
    await sellBloc.stream.firstWhere((state) => state.errorMessage != null);
    expect(sellBloc.state.status, OrderPlacementStatus.failed);
    expect(sellBloc.state.errorMessage, 'No holdings available to sell.');
    expect(sellRepository.calls, 0);
    await sellBloc.close();
  });

  test(
    'live LTP updates market value but preserves user price fields',
    () async {
      final repository = _BlocRepository(_instrument());
      final platform = _PricePlatform();
      final manager = LivePriceStreamManager(platform);
      final bloc = OrderPlacementBloc(repository, manager)
        ..add(const OrderPlacementStarted(fundId: 'equity'));
      await bloc.stream.firstWhere(
        (state) => state.status == OrderPlacementStatus.ready,
      );
      bloc.add(const OrderQuantityChanged('10'));
      await Future<void>.delayed(Duration.zero);

      platform.emit(ltpMinor: 10100, previousLtpMinor: 10000, sequence: 1);
      await bloc.stream.firstWhere((state) => state.instrument?.ltp == 101);
      expect(bloc.state.estimatedOrderValue, 1010);

      bloc.add(const OrderTypeChanged(TradeOrderType.limit));
      bloc.add(const OrderLimitPriceChanged('95'));
      await Future<void>.delayed(Duration.zero);
      platform.emit(ltpMinor: 10200, previousLtpMinor: 10100, sequence: 2);
      await bloc.stream.firstWhere((state) => state.instrument?.ltp == 102);
      expect(bloc.state.limitPrice, 95);
      expect(bloc.state.quantity, 10);
      await bloc.close();
      await platform.close();
    },
  );

  test('market confirmation snapshots the latest shared cache', () async {
    final repository = _BlocRepository(_instrument());
    final platform = _PricePlatform();
    final manager = LivePriceStreamManager(platform);
    final bloc = OrderPlacementBloc(repository, manager)
      ..add(const OrderPlacementStarted(fundId: 'equity'));
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.ready,
    );
    bloc.add(const OrderQuantityChanged('10'));
    bloc.add(const OrderReviewRequested());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.review,
    );
    platform.emit(ltpMinor: 10100, previousLtpMinor: 10000, sequence: 1);
    await bloc.stream.firstWhere((state) => state.instrument?.ltp == 101);

    bloc.add(const OrderPlacementConfirmed());
    await bloc.stream.firstWhere(
      (state) => state.status == OrderPlacementStatus.success,
    );
    expect(repository.drafts.single.instrument.ltp, 101);
    expect(repository.drafts.single.estimatedOrderValue, 1010);
    await bloc.close();
    await platform.close();
  });

  test(
    'incoming BSE defaults the ticket and exchange switch updates value',
    () async {
      final repository = _BlocRepository(_instrument());
      final platform = _PricePlatform();
      final bloc =
          OrderPlacementBloc(repository, LivePriceStreamManager(platform))..add(
            const OrderPlacementStarted(
              fundId: 'fund',
              exchange: TradeExchange.bse,
            ),
          );
      await bloc.stream.firstWhere(
        (state) => state.status == OrderPlacementStatus.ready,
      );

      expect(bloc.state.exchange, TradeExchange.bse);
      expect(bloc.state.instrument?.ltp, 99);
      bloc.add(const OrderQuantityChanged('10'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.estimatedOrderValue, 990);

      bloc.add(const OrderExchangeChanged(TradeExchange.nse));
      await bloc.stream.firstWhere(
        (state) => state.exchange == TradeExchange.nse,
      );
      expect(bloc.state.instrument?.ltp, 100);
      expect(bloc.state.quantity, 10);
      expect(bloc.state.estimatedOrderValue, 1000);
      await bloc.close();
      await platform.close();
    },
  );
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
  marketByExchange: const {
    TradeExchange.nse: OrderMarketListing(
      ltp: 100,
      previousClose: 99,
      tickSize: .05,
    ),
    TradeExchange.bse: OrderMarketListing(
      ltp: 99,
      previousClose: 98,
      tickSize: .05,
    ),
  },
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
  double availableFunds = 1000000000;
  int availableSellQuantity = 100000;

  @override
  Future<double> addFunds(double amount) async {
    availableFunds += amount;
    return availableFunds;
  }

  @override
  Future<double> getAvailableFunds() async => availableFunds;

  @override
  Stream<void> get positionChanges => const Stream.empty();
  @override
  Future<int> getAvailableSellQuantity({
    required String fundId,
    required TradeExchange exchange,
  }) async => availableSellQuantity;
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

final class _AccountFundsApi implements AccountFundsLocalApi {
  const _AccountFundsApi();

  @override
  List<LinkedBankAccountDto> get linkedBanks => const [];

  @override
  Stream<double> get balanceChanges => const Stream.empty();

  @override
  Future<AccountFundsStorageDto> read() async =>
      const AccountFundsStorageDto(availableBalance: 1000000000, deposits: []);

  @override
  Future<AccountFundsStorageDto> addFunds({
    required String depositId,
    required double amount,
    required String bankId,
  }) => read();

  @override
  Future<AccountFundsStorageDto> debitFunds({required double amount}) => read();
}

final class _TrackingAccountFundsApi implements AccountFundsLocalApi {
  _TrackingAccountFundsApi(this.balance);

  double balance;
  final addedAmounts = <double>[];

  @override
  Stream<double> get balanceChanges => const Stream.empty();

  @override
  List<LinkedBankAccountDto> get linkedBanks => const [DemoLinkedBanks.hdfc];

  @override
  Future<AccountFundsStorageDto> read() async =>
      AccountFundsStorageDto(availableBalance: balance, deposits: const []);

  @override
  Future<AccountFundsStorageDto> debitFunds({required double amount}) async {
    balance -= amount;
    return read();
  }

  @override
  Future<AccountFundsStorageDto> addFunds({
    required String depositId,
    required double amount,
    required String bankId,
  }) async {
    addedAmounts.add(amount);
    balance += amount;
    return read();
  }
}

final class _PricePlatform implements LivePricePlatformApi {
  final _controller = StreamController<Object?>.broadcast();

  @override
  Stream<Object?> get batches => _controller.stream;

  void emit({
    required int ltpMinor,
    required int previousLtpMinor,
    required int sequence,
  }) {
    _controller.add({
      'sequence': sequence,
      'timestamp': 1787460000000,
      'updates': [
        {
          'instrumentId': 'fund',
          'symbol': 'TEST',
          'ltpMinor': ltpMinor,
          'previousLtpMinor': previousLtpMinor,
          'previousCloseMinor': 10000,
          'changeMinor': ltpMinor - 10000,
          'changePercent': (ltpMinor - 10000) / 100,
          'direction': ltpMinor > previousLtpMinor ? 'up' : 'flat',
        },
      ],
    });
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {}
  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {}
  Future<void> close() => _controller.close();
}
