import 'package:core_data/core_data.dart';
import 'package:core_data/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fund/fund.dart';
import 'package:fund/src/fund_details/data/repositories/fund_repository_impl.dart';
import 'package:fund/src/fund_details/data/repositories/fund_watchlist_repository_impl.dart';
import 'package:get_it/get_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FundRepositoryImpl realFundRepository;
  late FundDetails reliance;

  setUpAll(() async {
    final getIt = GetIt.asNewInstance();
    registerCoreDataDependencies(getIt);
    realFundRepository = FundRepositoryImpl(getIt<TradingLocalApi>());
    reliance = await realFundRepository.getFundById('RELIANCE_EQ');
  });

  test(
    'repository resolves equity, future, option, and typed missing ID',
    () async {
      expect(reliance.instrumentType, FundInstrumentType.equity);
      expect(
        (await realFundRepository.getFundById(
          'TCS_FUT_20260825',
        )).instrumentType,
        FundInstrumentType.future,
      );
      expect(
        (await realFundRepository.getFundById(
          'SBIN_OPT_1050_CE_20260825',
        )).instrumentType,
        FundInstrumentType.option,
      );
      expect(
        () => realFundRepository.getFundById('MISSING'),
        throwsA(isA<FundNotFoundException>()),
      );
    },
  );

  test('repository attaches the underlying company profile', () async {
    final tcsFuture = await realFundRepository.getFundById('TCS_FUT_20260825');

    expect(reliance.companyProfile.legalName, 'Reliance Industries Limited');
    expect(reliance.companyProfile.directors, isNotEmpty);
    expect(reliance.companyProfile.management, isNotEmpty);
    expect(
      tcsFuture.companyProfile.legalName,
      'Tata Consultancy Services Limited',
    );
    expect(tcsFuture.companyProfile.corporateIdentityNumber, isNotEmpty);
  });

  test(
    'watchlist repository reads, persists, and prevents duplicates',
    () async {
      final api = _MemoryWatchlistApi();
      final repository = FundWatchlistRepositoryImpl(api);
      expect(
        (await repository.getAvailableWatchlists()).single.name,
        'Default',
      );

      await repository.addFundToWatchlist(
        watchlistId: 'watchlist_default',
        fundId: 'AXISBANK_EQ',
      );
      expect(api.watchlists.single.fundIds, contains('AXISBANK_EQ'));
      await expectLater(
        repository.addFundToWatchlist(
          watchlistId: 'watchlist_default',
          fundId: 'AXISBANK_EQ',
        ),
        throwsA(isA<FundAlreadyInWatchlistException>()),
      );
      expect(
        api.watchlists.single.fundIds.where((id) => id == 'AXISBANK_EQ'),
        hasLength(1),
      );

      await repository.removeFundFromWatchlist(
        watchlistId: 'watchlist_default',
        fundId: 'AXISBANK_EQ',
      );
      expect(api.watchlists.single.fundIds, isNot(contains('AXISBANK_EQ')));
    },
  );

  test(
    'repository resolves the selected exchange listing and market depth',
    () async {
      final nse = await realFundRepository.getFundById(
        'RELIANCE_EQ',
        exchange: TradeExchange.nse,
      );
      final bse = await realFundRepository.getFundById(
        'RELIANCE_EQ',
        exchange: TradeExchange.bse,
      );

      expect(nse.exchange, TradeExchange.nse);
      expect(bse.exchange, TradeExchange.bse);
      expect(bse.ltp, isNot(nse.ltp));
      expect(bse.previousClose, isNot(nse.previousClose));
      expect(
        bse.marketDepth.bids.first.price,
        isNot(nse.marketDepth.bids.first.price),
      );
    },
  );

  test(
    'bloc loads concurrently and changes history without refetching',
    () async {
      final funds = _FakeFundRepository(reliance);
      final watchlists = _FakeFundWatchlistRepository();
      final bloc = FundDetailsBloc(funds, watchlists);
      final loaded = expectLater(
        bloc.stream,
        emitsThrough(
          predicate<FundDetailsState>(
            (state) => state.status == FundDetailsStatus.loaded,
          ),
        ),
      );
      bloc.add(const FundDetailsStarted(fundId: 'RELIANCE_EQ'));
      await loaded;
      expect(bloc.state.selectedHistoryPeriod, FundHistoryPeriod.oneMonth);
      expect(bloc.state.availableWatchlists.first.name, 'Default');
      expect(bloc.state.isFundInWatchlist, isTrue);
      expect(bloc.state.selectedWatchlistId, 'watchlist_default');

      bloc.add(const FundHistoryPeriodChanged(FundHistoryPeriod.threeMonths));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedHistoryPeriod, FundHistoryPeriod.threeMonths);
      expect(funds.calls, 1);
      expect(watchlists.readCalls, 1);
      await bloc.close();
    },
  );

  test(
    'bloc selection does not persist and add updates loaded membership',
    () async {
      final funds = _FakeFundRepository(reliance);
      final watchlists = _FakeFundWatchlistRepository();
      final bloc = FundDetailsBloc(funds, watchlists);
      bloc.add(const FundDetailsStarted(fundId: 'RELIANCE_EQ'));
      await bloc.stream.firstWhere(
        (state) => state.status == FundDetailsStatus.loaded,
      );

      bloc.add(const FundWatchlistSelected(watchlistId: 'secondary'));
      await Future<void>.delayed(Duration.zero);
      expect(watchlists.addCalls, 0);
      bloc.add(const FundAddToWatchlistRequested());
      await bloc.stream.firstWhere(
        (state) => state.message == 'Added to Watchlist 2',
      );
      expect(watchlists.addCalls, 1);
      expect(
        bloc.state.availableWatchlists.last.containsFund(reliance.id),
        isTrue,
      );
      await bloc.close();
    },
  );

  test(
    'bloc removes persisted membership and updates bookmark state',
    () async {
      final funds = _FakeFundRepository(reliance);
      final watchlists = _FakeFundWatchlistRepository();
      final bloc = FundDetailsBloc(funds, watchlists);
      bloc.add(const FundDetailsStarted(fundId: 'RELIANCE_EQ'));
      await bloc.stream.firstWhere(
        (state) => state.status == FundDetailsStatus.loaded,
      );

      expect(bloc.state.isFundInWatchlist, isTrue);
      bloc.add(const FundRemoveFromWatchlistRequested());
      await bloc.stream.firstWhere(
        (state) => state.message == 'Removed from Default',
      );

      expect(watchlists.removeCalls, 1);
      expect(watchlists.removedWatchlistId, 'watchlist_default');
      expect(bloc.state.isFundInWatchlist, isFalse);
      await bloc.close();
    },
  );

  test('recent activity uses reactive orders filtered by fund ID', () async {
    final orderApi = _MemoryOrderApi();
    final store = OrderStore(orderApi);
    await store.append(_activityOrder('reliance', 'RELIANCE_EQ', 'open'));
    await store.append(_activityOrder('tcs', 'TCS_EQ', 'executed'));
    final bloc = FundDetailsBloc(
      _FakeFundRepository(reliance),
      _FakeFundWatchlistRepository(),
      null,
      store,
    )..add(const FundDetailsStarted(fundId: 'RELIANCE_EQ'));
    await bloc.stream.firstWhere(
      (state) => state.status == FundDetailsStatus.loaded,
    );

    expect(bloc.state.fund!.recentActivity, hasLength(1));
    expect(bloc.state.fund!.recentActivity.single.id, 'reliance');
    expect(bloc.state.fund!.recentActivity.single.title, 'BUY · OPEN');

    await store.replace(_activityOrder('reliance', 'RELIANCE_EQ', 'executed'));
    await bloc.stream.firstWhere(
      (state) => state.fund!.recentActivity.single.title.contains('EXECUTED'),
    );
    expect(
      bloc.state.fund!.recentActivity.single.description,
      contains('Bought 10'),
    );
    await bloc.close();
  });
}

OrderDto _activityOrder(String id, String fundId, String status) => OrderDto(
  id: id,
  fundId: fundId,
  symbol: fundId == 'RELIANCE_EQ' ? 'RELIANCE' : 'TCS',
  companyName: 'Company',
  exchange: 'nse',
  instrumentType: 'equity',
  side: 'buy',
  orderType: 'limit',
  productType: 'delivery',
  status: status,
  quantity: 10,
  filledQuantity: status == 'executed' ? 10 : 0,
  pendingQuantity: status == 'executed' ? 0 : 10,
  ltp: 100,
  averagePrice: status == 'executed' ? 100 : null,
  limitPrice: 100,
  orderValue: 1000,
  validity: 'DAY',
  createdAt: DateTime(2026),
  updatedAt: status == 'executed' ? DateTime(2026, 1, 2) : DateTime(2026),
);

final class _MemoryOrderApi implements OrderBookLocalApi {
  List<OrderDto> orders = const [];

  @override
  Future<List<OrderDto>> getOrders() async => orders;

  @override
  Future<void> saveOrders(List<OrderDto> orders) async {
    this.orders = List.unmodifiable(orders);
  }
}

final class _MemoryWatchlistApi implements WatchlistLocalApi {
  _MemoryWatchlistApi()
    : watchlists = [
        WatchlistDto(
          id: 'watchlist_default',
          name: 'Default',
          fundIds: const [],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
  List<WatchlistDto> watchlists;

  @override
  Stream<void> get watchlistChanges => const Stream<void>.empty();

  @override
  Future<List<WatchlistDto>> getWatchlists() async =>
      List.unmodifiable(watchlists);
  @override
  Future<void> saveWatchlists(List<WatchlistDto> watchlists) async =>
      this.watchlists = List.unmodifiable(watchlists);
}

final class _FakeFundRepository implements FundRepository {
  _FakeFundRepository(this.fund);
  final FundDetails fund;
  int calls = 0;
  @override
  Future<FundDetails> getFundById(
    String fundId, {
    TradeExchange exchange = TradeExchange.nse,
  }) async {
    calls++;
    return fund;
  }
}

final class _FakeFundWatchlistRepository implements FundWatchlistRepository {
  int readCalls = 0;
  int addCalls = 0;
  int removeCalls = 0;
  String? removedWatchlistId;
  final items = <AvailableWatchlist>[
    AvailableWatchlist(
      id: 'watchlist_default',
      name: 'Default',
      fundIds: const ['RELIANCE_EQ'],
    ),
    AvailableWatchlist(id: 'secondary', name: 'Watchlist 2', fundIds: const []),
  ];
  @override
  Future<List<AvailableWatchlist>> getAvailableWatchlists() async {
    readCalls++;
    return List.unmodifiable(items);
  }

  @override
  Future<void> addFundToWatchlist({
    required String watchlistId,
    required String fundId,
  }) async {
    addCalls++;
  }

  @override
  Future<void> removeFundFromWatchlist({
    required String watchlistId,
    required String fundId,
  }) async {
    removeCalls++;
    removedWatchlistId = watchlistId;
  }
}
