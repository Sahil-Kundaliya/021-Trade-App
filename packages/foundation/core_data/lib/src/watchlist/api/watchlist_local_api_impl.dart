import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../cache/key_value_storage.dart';
import '../exceptions/watchlist_data_exception.dart';
import '../models/watchlist_dto.dart';
import 'watchlist_local_api.dart';

@LazySingleton(as: WatchlistLocalApi)
final class WatchlistLocalApiImpl implements WatchlistLocalApi {
  WatchlistLocalApiImpl(this._storage);

  static const _storageKey = 'trading_watchlists_v1';
  static const _requestDelay = Duration(milliseconds: 800);
  static const _maximumWatchlists = 5;

  final KeyValueStorage _storage;

  @override
  Future<List<WatchlistDto>> getWatchlists() async {
    await Future<void>.delayed(_requestDelay);
    try {
      final source = await _storage.getString(_storageKey);
      if (source == null || source.trim().isEmpty) {
        final defaults = _defaultWatchlists();
        await _persist(defaults);
        return defaults;
      }
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic> || decoded['watchlists'] is! List) {
        throw const FormatException('Invalid watchlist document.');
      }
      final watchlists = (decoded['watchlists'] as List)
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const FormatException('Invalid watchlist entry.');
            }
            return WatchlistDto.fromJson(value);
          })
          .toList(growable: false);
      _validate(watchlists);
      return List<WatchlistDto>.unmodifiable(watchlists);
    } on WatchlistDataException {
      rethrow;
    } on Object catch (error) {
      throw WatchlistDataException('Unable to read watchlists.', error);
    }
  }

  @override
  Future<void> saveWatchlists(List<WatchlistDto> watchlists) async {
    await Future<void>.delayed(_requestDelay);
    try {
      _validate(watchlists);
      await _persist(watchlists);
    } on WatchlistDataException {
      rethrow;
    } on Object catch (error) {
      throw WatchlistDataException('Unable to save watchlists.', error);
    }
  }

  Future<void> _persist(List<WatchlistDto> watchlists) => _storage.setString(
    _storageKey,
    jsonEncode(<String, dynamic>{
      'watchlists': watchlists.map((item) => item.toJson()).toList(),
    }),
  );

  static void _validate(List<WatchlistDto> watchlists) {
    if (watchlists.length > _maximumWatchlists) {
      throw const WatchlistDataException(
        'A maximum of 5 watchlists is allowed.',
      );
    }
    final ids = <String>{};
    final names = <String>{};
    for (final watchlist in watchlists) {
      final normalizedName = watchlist.name.trim().toLowerCase();
      if (watchlist.id.trim().isEmpty || normalizedName.isEmpty) {
        throw const WatchlistDataException(
          'Watchlist IDs and names are required.',
        );
      }
      if (!ids.add(watchlist.id) || !names.add(normalizedName)) {
        throw const WatchlistDataException(
          'Watchlist IDs and names must be unique.',
        );
      }
      if (watchlist.fundIds.toSet().length != watchlist.fundIds.length) {
        throw const WatchlistDataException(
          'Fund IDs must be unique per watchlist.',
        );
      }
    }
  }

  static List<WatchlistDto> _defaultWatchlists() {
    final now = DateTime.now();
    return List<WatchlistDto>.unmodifiable(<WatchlistDto>[
      WatchlistDto(
        id: 'watchlist_default',
        name: 'Default',
        fundIds: const <String>[
          'RELIANCE_EQ',
          'TCS_EQ',
          'INFY_EQ',
          'HDFCBANK_EQ',
          'ICICIBANK_EQ',
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }
}
