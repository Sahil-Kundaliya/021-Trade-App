import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist/src/watchlist/domain/entities/watchlist.dart';
import 'package:watchlist/src/watchlist/domain/entities/watchlist_fund.dart';
import 'package:watchlist/src/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:watchlist/src/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:watchlist/src/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:watchlist/src/watchlist/presentation/bloc/watchlist_state.dart';

void main() {
  late _FakeRepository repository;
  late WatchlistBloc bloc;

  setUp(() async {
    repository = _FakeRepository();
    bloc = WatchlistBloc(repository);
    final loaded = bloc.stream.firstWhere(
      (state) => state.status == WatchlistStatus.loaded,
    );
    bloc.add(const WatchlistStarted());
    await loaded;
  });

  tearDown(() => bloc.close());

  test('started selects Default and resolves funds in fundIds order', () {
    expect(bloc.state.selectedWatchlistId, 'watchlist_default');
    expect(bloc.state.visibleFunds.map((fund) => fund.id), [
      'INFY_EQ',
      'RELIANCE_EQ',
      'TCS_EQ',
    ]);
  });

  test('selection resolves locally without another repository read', () async {
    final readsBefore = repository.readCount;
    final changed = bloc.stream.firstWhere(
      (state) => state.selectedWatchlistId == 'watchlist_2',
    );
    bloc.add(const WatchlistSelected(watchlistId: 'watchlist_2'));
    await changed;

    expect(bloc.state.visibleFunds.map((fund) => fund.id), ['RELIANCE_EQ']);
    expect(repository.readCount, readsBefore);
  });

  test('create and rename validate and persist immutable updates', () async {
    final created = bloc.stream.firstWhere(
      (state) => state.watchlists.length == 3,
    );
    bloc.add(const WatchlistCreateRequested(name: '  Growth  '));
    await created;
    final growth = bloc.state.watchlists.singleWhere(
      (item) => item.name == 'Growth',
    );

    final renamed = bloc.stream.firstWhere(
      (state) => state.watchlists.any((item) => item.name == 'Long Term'),
    );
    bloc.add(
      WatchlistRenameRequested(watchlistId: growth.id, newName: ' Long Term '),
    );
    await renamed;

    expect(repository.saveCount, 2);
    expect(
      bloc.state.watchlists.any((item) => item.name == 'Long Term'),
      isTrue,
    );
  });

  test('does not create a sixth watchlist', () async {
    for (var index = 3; index <= 5; index++) {
      final count = index;
      final changed = bloc.stream.firstWhere(
        (state) => state.watchlists.length == count,
      );
      bloc.add(WatchlistCreateRequested(name: 'Watchlist $index'));
      await changed;
    }
    final savesBefore = repository.saveCount;
    final rejected = bloc.stream.firstWhere((state) => state.message != null);
    bloc.add(const WatchlistCreateRequested(name: 'Sixth'));
    await rejected;

    expect(bloc.state.watchlists, hasLength(5));
    expect(repository.saveCount, savesBefore);
  });

  test(
    'Default cannot be deleted and another watchlist can be deleted',
    () async {
      final rejected = bloc.stream.firstWhere((state) => state.message != null);
      bloc.add(
        const WatchlistDeleteRequested(watchlistId: 'watchlist_default'),
      );
      await rejected;
      expect(bloc.state.watchlists, hasLength(2));

      final deleted = bloc.stream.firstWhere(
        (state) => state.watchlists.length == 1,
      );
      bloc.add(const WatchlistDeleteRequested(watchlistId: 'watchlist_2'));
      await deleted;
      expect(bloc.state.watchlists.single.id, 'watchlist_default');
    },
  );

  test(
    'add prevents duplicates but allows the same fund in another watchlist',
    () async {
      final added = bloc.stream.firstWhere(
        (state) => state.watchlists.last.fundIds.contains('TCS_EQ'),
      );
      bloc.add(
        const WatchlistFundAddRequested(
          watchlistId: 'watchlist_2',
          fundId: 'TCS_EQ',
        ),
      );
      await added;
      expect(bloc.state.watchlists.first.fundIds, contains('TCS_EQ'));
      expect(bloc.state.watchlists.last.fundIds, contains('TCS_EQ'));

      final savesBefore = repository.saveCount;
      final rejected = bloc.stream.firstWhere((state) => state.message != null);
      bloc.add(
        const WatchlistFundAddRequested(
          watchlistId: 'watchlist_2',
          fundId: 'TCS_EQ',
        ),
      );
      await rejected;
      expect(repository.saveCount, savesBefore);
    },
  );

  test('remove affects only its target watchlist', () async {
    final removed = bloc.stream.firstWhere(
      (state) => !state.watchlists.last.fundIds.contains('RELIANCE_EQ'),
    );
    bloc.add(
      const WatchlistFundRemoveRequested(
        watchlistId: 'watchlist_2',
        fundId: 'RELIANCE_EQ',
      ),
    );
    await removed;
    expect(bloc.state.watchlists.first.fundIds, contains('RELIANCE_EQ'));
  });

  test('reorder persists and preserves the requested order', () async {
    final reordered = bloc.stream.firstWhere(
      (state) => state.watchlists.first.fundIds.first == 'TCS_EQ',
    );
    bloc.add(
      const WatchlistFundsReorderRequested(
        watchlistId: 'watchlist_default',
        oldIndex: 2,
        newIndex: 0,
      ),
    );
    await reordered;
    expect(bloc.state.watchlists.first.fundIds, [
      'TCS_EQ',
      'INFY_EQ',
      'RELIANCE_EQ',
    ]);
    expect(bloc.state.visibleFunds.map((fund) => fund.id), [
      'TCS_EQ',
      'INFY_EQ',
      'RELIANCE_EQ',
    ]);
  });
}

final class _FakeRepository implements WatchlistRepository {
  int readCount = 0;
  int saveCount = 0;
  late List<Watchlist> _watchlists = <Watchlist>[
    _watchlist('watchlist_default', 'Default', [
      'INFY_EQ',
      'RELIANCE_EQ',
      'TCS_EQ',
    ]),
    _watchlist('watchlist_2', 'Watchlist 2', ['RELIANCE_EQ']),
  ];
  final List<WatchlistFund> _funds = <WatchlistFund>[
    _fund('RELIANCE_EQ', 'RELIANCE'),
    _fund('TCS_EQ', 'TCS'),
    _fund('INFY_EQ', 'INFY'),
  ];

  @override
  Future<List<Watchlist>> getWatchlists() async {
    readCount += 1;
    return _watchlists;
  }

  @override
  Future<List<WatchlistFund>> getAllFunds() async {
    readCount += 1;
    return _funds;
  }

  @override
  Future<List<WatchlistFund>> getFundsForWatchlist(Watchlist watchlist) async =>
      _funds.where((fund) => watchlist.fundIds.contains(fund.id)).toList();

  @override
  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    saveCount += 1;
    _watchlists = List<Watchlist>.of(watchlists);
  }
}

Watchlist _watchlist(String id, String name, List<String> fundIds) {
  final now = DateTime(2026, 8, 22);
  return Watchlist(
    id: id,
    name: name,
    fundIds: fundIds,
    createdAt: now,
    updatedAt: now,
  );
}

WatchlistFund _fund(String id, String symbol) => WatchlistFund(
  id: id,
  symbol: symbol,
  companyName: symbol,
  exchange: 'NSE',
  category: 'Equity',
  ltp: 100,
  change: 1,
  changePercent: 1,
  tags: const ['Recommended'],
);
