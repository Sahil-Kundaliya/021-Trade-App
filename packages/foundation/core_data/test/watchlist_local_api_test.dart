import 'dart:convert';

import 'package:core_data/core_data.dart';
import 'package:core_data/src/watchlist/api/watchlist_local_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchlistLocalApi', () {
    test(
      'missing storage returns an empty runtime Default without writing',
      () async {
        final storage = _MemoryStorage();
        final api = WatchlistLocalApiImpl(storage);

        final result = await api.getWatchlists();

        expect(result, hasLength(1));
        expect(result.single.id, 'watchlist_default');
        expect(result.single.name, 'Default');
        expect(result.single.fundIds, isEmpty);
        expect(storage.readKeys, <String>['trading_watchlists_v1']);
        expect(storage.writeCount, 0);
        expect(storage.values, isEmpty);
      },
    );

    test(
      'creates Default first and preserves stored user watchlist order',
      () async {
        final storage = _MemoryStorage(
          initialValues: <String, String>{
            'trading_watchlists_v1': jsonEncode(<String, dynamic>{
              'defaultFundIds': <String>['TCS_EQ'],
              'watchlists': <Map<String, dynamic>>[
                _watchlistJson('banking', 'Banking', <String>['HDFCBANK_EQ']),
                _watchlistJson('long_term', 'Long Term', <String>[]),
              ],
            }),
          },
        );
        final api = WatchlistLocalApiImpl(storage);

        final result = await api.getWatchlists();

        expect(result.map((item) => item.name), <String>[
          'Default',
          'Banking',
          'Long Term',
        ]);
        expect(result.first.id, 'watchlist_default');
        expect(result.first.fundIds, <String>['TCS_EQ']);
        expect(result[1].fundIds, <String>['HDFCBANK_EQ']);
        expect(storage.writeCount, 0);
      },
    );

    test('save stores Default fund IDs but never a Default record', () async {
      final storage = _MemoryStorage();
      final api = WatchlistLocalApiImpl(storage);
      final now = DateTime.parse('2026-08-22T10:00:00+05:30');
      final changed = api.watchlistChanges.first;

      await api.saveWatchlists(<WatchlistDto>[
        WatchlistDto(
          id: 'watchlist_default',
          name: 'Default',
          fundIds: const <String>['RELIANCE_EQ'],
          createdAt: now,
          updatedAt: now,
        ),
        WatchlistDto(
          id: 'watchlist_banking',
          name: 'Banking',
          fundIds: const <String>['HDFCBANK_EQ'],
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      await changed;

      expect(storage.writeCount, 1);
      expect(storage.values, hasLength(1));
      final stored =
          jsonDecode(storage.values['trading_watchlists_v1']!)
              as Map<String, dynamic>;
      expect(
        stored.keys,
        unorderedEquals(<String>[
          'defaultName',
          'defaultFundIds',
          'watchlists',
        ]),
      );
      expect(stored['defaultName'], 'Default');
      expect(stored['defaultFundIds'], <String>['RELIANCE_EQ']);
      final users = stored['watchlists'] as List<dynamic>;
      expect(users, hasLength(1));
      expect((users.single as Map<String, dynamic>)['id'], 'watchlist_banking');
      expect(
        users.where(
          (item) => (item as Map<String, dynamic>)['id'] == 'watchlist_default',
        ),
        isEmpty,
      );

      final result = await api.getWatchlists();
      expect(result.map((item) => item.id), <String>[
        'watchlist_default',
        'watchlist_banking',
      ]);
      expect(result.first.fundIds, <String>['RELIANCE_EQ']);
      expect(result.last.fundIds, <String>['HDFCBANK_EQ']);
    });

    test(
      'reads a missing defaultName without performing a migration write',
      () async {
        final storage = _MemoryStorage(
          initialValues: <String, String>{
            'trading_watchlists_v1': jsonEncode(<String, dynamic>{
              'defaultFundIds': <String>['RELIANCE_EQ'],
              'watchlists': <dynamic>[],
            }),
          },
        );
        final api = WatchlistLocalApiImpl(storage);

        final result = await api.getWatchlists();

        expect(result.single.name, 'Default');
        expect(storage.writeCount, 0);
      },
    );

    test(
      'persists a renamed runtime Default without storing it as a user item',
      () async {
        final storage = _MemoryStorage();
        final api = WatchlistLocalApiImpl(storage);
        final now = DateTime.parse('2026-08-22T10:00:00+05:30');

        await api.saveWatchlists(<WatchlistDto>[
          WatchlistDto(
            id: 'watchlist_default',
            name: 'Main',
            fundIds: const <String>['RELIANCE_EQ'],
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        final stored =
            jsonDecode(storage.values['trading_watchlists_v1']!)
                as Map<String, dynamic>;
        expect(stored['defaultName'], 'Main');
        expect(stored['watchlists'], isEmpty);
        final result = await api.getWatchlists();
        expect(result.single.id, 'watchlist_default');
        expect(result.single.name, 'Main');
        expect(result.single.fundIds, <String>['RELIANCE_EQ']);
      },
    );

    test('rejects a fifth user-created watchlist', () async {
      final api = WatchlistLocalApiImpl(_MemoryStorage());
      final now = DateTime.now();
      final watchlists = <WatchlistDto>[
        WatchlistDto(
          id: 'watchlist_default',
          name: 'Default',
          fundIds: const <String>[],
          createdAt: now,
          updatedAt: now,
        ),
        ...List<WatchlistDto>.generate(
          5,
          (index) => WatchlistDto(
            id: 'watchlist_$index',
            name: 'User $index',
            fundIds: const <String>[],
            createdAt: now,
            updatedAt: now,
          ),
        ),
      ];

      await expectLater(
        api.saveWatchlists(watchlists),
        throwsA(isA<WatchlistDataException>()),
      );
    });

    test('rejects duplicate fund IDs within one watchlist', () async {
      final api = WatchlistLocalApiImpl(_MemoryStorage());
      final now = DateTime.now();

      await expectLater(
        api.saveWatchlists(<WatchlistDto>[
          WatchlistDto(
            id: 'watchlist_default',
            name: 'Default',
            fundIds: const <String>['RELIANCE_EQ', 'RELIANCE_EQ'],
            createdAt: now,
            updatedAt: now,
          ),
        ]),
        throwsA(isA<WatchlistDataException>()),
      );
    });
  });
}

Map<String, dynamic> _watchlistJson(
  String id,
  String name,
  List<String> fundIds,
) {
  const timestamp = '2026-08-22T10:00:00+05:30';
  return <String, dynamic>{
    'id': id,
    'name': name,
    'fundIds': fundIds,
    'createdAt': timestamp,
    'updatedAt': timestamp,
  };
}

final class _MemoryStorage implements KeyValueStorage {
  _MemoryStorage({Map<String, String>? initialValues})
    : values = <String, String>{...?initialValues};

  final Map<String, String> values;
  final List<String> readKeys = <String>[];
  int writeCount = 0;

  @override
  Future<void> setString(String key, String value) async {
    writeCount += 1;
    values[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    readKeys.add(key);
    return values[key];
  }

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}
