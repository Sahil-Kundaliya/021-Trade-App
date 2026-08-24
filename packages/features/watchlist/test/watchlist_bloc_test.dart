import 'dart:async';

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

  tearDown(() async {
    await bloc.close();
    await repository.close();
  });

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

  test('refreshes when another feature changes persisted funds', () async {
    final added = bloc.stream.firstWhere(
      (state) => state.visibleFunds.any((fund) => fund.id == 'AXISBANK_EQ'),
    );
    repository.replaceDefaultFundIds(<String>[
      'INFY_EQ',
      'RELIANCE_EQ',
      'TCS_EQ',
      'AXISBANK_EQ',
    ]);
    await added;

    expect(bloc.state.visibleFunds.map((fund) => fund.id), <String>[
      'INFY_EQ',
      'RELIANCE_EQ',
      'TCS_EQ',
      'AXISBANK_EQ',
    ]);

    final removed = bloc.stream.firstWhere(
      (state) => !state.visibleFunds.any((fund) => fund.id == 'INFY_EQ'),
    );
    repository.replaceDefaultFundIds(<String>[
      'RELIANCE_EQ',
      'TCS_EQ',
      'AXISBANK_EQ',
    ]);
    await removed;

    expect(bloc.state.visibleFunds.map((fund) => fund.id), <String>[
      'RELIANCE_EQ',
      'TCS_EQ',
      'AXISBANK_EQ',
    ]);
  });

  test('create and rename validate and persist immutable updates', () async {
    final created = bloc.stream.firstWhere(
      (state) => state.watchlists.length == 3 && !state.isSaving,
    );
    bloc.add(const WatchlistCreateRequested(name: '  Growth  '));
    await created;
    final growth = bloc.state.watchlists.singleWhere(
      (item) => item.name == 'Growth',
    );
    expect(growth.fundIds, isEmpty);

    final renamed = bloc.stream.firstWhere(
      (state) =>
          state.watchlists.any((item) => item.name == 'Long Term') &&
          !state.isSaving,
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

  test('rename preserves stable ID, fund membership, and fund order', () async {
    final before = bloc.state.watchlists.singleWhere(
      (item) => item.id == 'watchlist_2',
    );
    final renamed = bloc.stream.firstWhere(
      (state) => state.watchlists.any((item) => item.name == 'Banks'),
    );

    bloc.add(
      const WatchlistRenameRequested(
        watchlistId: 'watchlist_2',
        newName: 'Banks',
      ),
    );
    await renamed;

    final after = bloc.state.watchlists.singleWhere(
      (item) => item.id == 'watchlist_2',
    );
    expect(after.id, before.id);
    expect(after.fundIds, before.fundIds);
    expect(after.createdAt, before.createdAt);
  });

  test('renames Default while preserving its ID and funds', () async {
    final before = bloc.state.watchlists.first;
    final renamed = bloc.stream.firstWhere(
      (state) => state.watchlists.first.name == 'Main',
    );

    bloc.add(
      const WatchlistRenameRequested(
        watchlistId: 'watchlist_default',
        newName: 'Main',
      ),
    );
    await renamed;

    expect(bloc.state.watchlists.first.id, 'watchlist_default');
    expect(bloc.state.watchlists.first.fundIds, before.fundIds);
  });

  test(
    'rejects duplicate names case-insensitively and names over 30 chars',
    () async {
      var rejected = bloc.stream.firstWhere((state) => state.message != null);
      bloc.add(const WatchlistCreateRequested(name: 'default'));
      await rejected;
      expect(repository.saveCount, 0);

      rejected = bloc.stream.firstWhere(
        (state) => state.message?.contains('30 characters') ?? false,
      );
      bloc.add(
        WatchlistCreateRequested(name: List<String>.filled(31, 'x').join()),
      );
      await rejected;
      expect(repository.saveCount, 0);
    },
  );

  test('failed rename keeps the previous name and fund membership', () async {
    repository.failSaves = true;
    final failed = bloc.stream.firstWhere(
      (state) => state.errorMessage != null && !state.isSaving,
    );

    bloc.add(
      const WatchlistRenameRequested(
        watchlistId: 'watchlist_2',
        newName: 'Banks',
      ),
    );
    await failed;

    final watchlist = bloc.state.watchlists.singleWhere(
      (item) => item.id == 'watchlist_2',
    );
    expect(watchlist.name, 'Watchlist 2');
    expect(watchlist.fundIds, <String>['RELIANCE_EQ']);
  });

  test('an effectively unchanged rename does not write', () async {
    bloc.add(
      const WatchlistRenameRequested(
        watchlistId: 'watchlist_2',
        newName: '  Watchlist 2  ',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(repository.saveCount, 0);
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
        (state) => state.watchlists.length == 1 && !state.isSaving,
      );
      bloc.add(const WatchlistDeleteRequested(watchlistId: 'watchlist_2'));
      await deleted;
      expect(bloc.state.watchlists.single.id, 'watchlist_default');
      expect(bloc.state.selectedWatchlistId, 'watchlist_default');
    },
  );

  test(
    'add prevents duplicates but allows the same fund in another watchlist',
    () async {
      final added = bloc.stream.firstWhere(
        (state) =>
            state.watchlists.last.fundIds.contains('TCS_EQ') && !state.isSaving,
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
      (state) =>
          !state.watchlists.last.fundIds.contains('RELIANCE_EQ') &&
          !state.isSaving,
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
      (state) =>
          state.watchlists.first.fundIds.first == 'TCS_EQ' && !state.isSaving,
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

  test('reorder stays optimistic while local persistence completes', () async {
    final saveGate = Completer<void>();
    repository.saveGate = saveGate;
    addTearDown(() {
      if (!saveGate.isCompleted) saveGate.complete();
    });

    final saving = bloc.stream.firstWhere((state) => state.isSaving);
    bloc.add(
      const WatchlistFundsReorderRequested(
        watchlistId: 'watchlist_default',
        oldIndex: 2,
        newIndex: 0,
      ),
    );
    final optimistic = await saving;

    expect(optimistic.visibleFunds.map((fund) => fund.id), [
      'TCS_EQ',
      'INFY_EQ',
      'RELIANCE_EQ',
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state.visibleFunds.map((fund) => fund.id), [
      'TCS_EQ',
      'INFY_EQ',
      'RELIANCE_EQ',
    ]);

    final saved = bloc.stream.firstWhere((state) => !state.isSaving);
    saveGate.complete();
    await saved;
    expect(bloc.state.visibleFunds.map((fund) => fund.id), [
      'TCS_EQ',
      'INFY_EQ',
      'RELIANCE_EQ',
    ]);
  });

  test('reorders user watchlists and keeps Default first', () async {
    final created = bloc.stream.firstWhere(
      (state) => state.watchlists.length == 3 && !state.isSaving,
    );
    bloc.add(const WatchlistCreateRequested(name: 'Banks'));
    await created;
    final beforeIds = bloc.state.watchlists.map((item) => item.id).toList();
    final banks = bloc.state.watchlists.last;
    expect(beforeIds.first, 'watchlist_default');

    final reordered = bloc.stream.firstWhere(
      (state) =>
          state.watchlists.length == 3 &&
          state.watchlists[1].id == banks.id &&
          !state.isSaving,
    );
    bloc.add(const WatchlistsReorderRequested(oldIndex: 1, newIndex: 0));
    await reordered;

    expect(bloc.state.watchlists.map((item) => item.id), [
      'watchlist_default',
      banks.id,
      'watchlist_2',
    ]);
    expect(bloc.state.watchlists[1].fundIds, banks.fundIds);
    expect(repository.saveCount, 2);
  });

  test('restore previous order when watchlist reorder save fails', () async {
    final created = bloc.stream.firstWhere(
      (state) => state.watchlists.length == 3 && !state.isSaving,
    );
    bloc.add(const WatchlistCreateRequested(name: 'Banks'));
    await created;
    final previous = bloc.state.watchlists.map((item) => item.id).toList();
    repository.failSaves = true;
    final rejected = bloc.stream.firstWhere((state) => state.message != null);
    bloc.add(const WatchlistsReorderRequested(oldIndex: 1, newIndex: 0));
    await rejected;
    expect(bloc.state.message, 'Unable to reorder watchlists.');
    expect(bloc.state.watchlists.map((item) => item.id), previous);
  });
}

final class _FakeRepository implements WatchlistRepository {
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  int readCount = 0;
  int saveCount = 0;
  bool failSaves = false;
  Completer<void>? saveGate;
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
    _fund('AXISBANK_EQ', 'AXISBANK'),
  ];

  @override
  Stream<void> get watchlistChanges => _changes.stream;

  void replaceDefaultFundIds(List<String> fundIds) {
    _watchlists = <Watchlist>[
      _watchlists.first.copyWith(fundIds: fundIds, updatedAt: DateTime.now()),
      ..._watchlists.skip(1),
    ];
    _changes.add(null);
  }

  Future<void> close() => _changes.close();

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
    await saveGate?.future;
    if (failSaves) throw StateError('storage unavailable');
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
