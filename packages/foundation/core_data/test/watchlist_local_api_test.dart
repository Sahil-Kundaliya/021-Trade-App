import 'package:core_data/core_data.dart';
import 'package:core_data/src/watchlist/api/watchlist_local_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WatchlistLocalApi', () {
    test('creates, persists, and returns defaults on first read', () async {
      final storage = _MemoryStorage();
      final api = WatchlistLocalApiImpl(storage);

      final result = await api.getWatchlists();

      expect(result, hasLength(1));
      expect(result.first.id, 'watchlist_default');
      expect(result.first.name, 'Default');
      expect(result.first.fundIds, <String>[
        'RELIANCE_EQ',
        'TCS_EQ',
        'INFY_EQ',
        'HDFCBANK_EQ',
        'ICICIBANK_EQ',
      ]);
      expect(await storage.getString('trading_watchlists_v1'), isNotNull);

      final subsequent = await api.getWatchlists();
      expect(
        subsequent.map((item) => item.name),
        result.map((item) => item.name),
      );
    });

    test('save then read preserves names and fund ordering', () async {
      final api = WatchlistLocalApiImpl(_MemoryStorage());
      final now = DateTime.parse('2026-08-22T10:00:00+05:30');
      final expected = <WatchlistDto>[
        WatchlistDto(
          id: 'watchlist_default',
          name: 'Default',
          fundIds: const ['INFY_EQ', 'RELIANCE_EQ', 'TCS_EQ'],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await api.saveWatchlists(expected);
      final actual = await api.getWatchlists();

      expect(actual.single.name, 'Default');
      expect(actual.single.fundIds, <String>[
        'INFY_EQ',
        'RELIANCE_EQ',
        'TCS_EQ',
      ]);
    });

    test('rejects more than five watchlists', () async {
      final api = WatchlistLocalApiImpl(_MemoryStorage());
      final now = DateTime.now();
      final watchlists = List<WatchlistDto>.generate(
        6,
        (index) => WatchlistDto(
          id: 'watchlist_$index',
          name: 'Watchlist $index',
          fundIds: const [],
          createdAt: now,
          updatedAt: now,
        ),
      );

      await expectLater(
        api.saveWatchlists(watchlists),
        throwsA(isA<WatchlistDataException>()),
      );
    });
  });
}

final class _MemoryStorage implements KeyValueStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
