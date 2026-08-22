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
        watchlistId: 'default',
        fundId: 'AXISBANK_EQ',
      );
      expect(api.watchlists.single.fundIds, contains('AXISBANK_EQ'));
      await expectLater(
        repository.addFundToWatchlist(
          watchlistId: 'default',
          fundId: 'AXISBANK_EQ',
        ),
        throwsA(isA<FundAlreadyInWatchlistException>()),
      );
      expect(
        api.watchlists.single.fundIds.where((id) => id == 'AXISBANK_EQ'),
        hasLength(1),
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
}

final class _MemoryWatchlistApi implements WatchlistLocalApi {
  _MemoryWatchlistApi()
    : watchlists = [
        WatchlistDto(
          id: 'default',
          name: 'Default',
          fundIds: const [],
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
  List<WatchlistDto> watchlists;
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
  Future<FundDetails> getFundById(String fundId) async {
    calls++;
    return fund;
  }
}

final class _FakeFundWatchlistRepository implements FundWatchlistRepository {
  int readCalls = 0;
  int addCalls = 0;
  final items = <AvailableWatchlist>[
    AvailableWatchlist(
      id: 'default',
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
}
