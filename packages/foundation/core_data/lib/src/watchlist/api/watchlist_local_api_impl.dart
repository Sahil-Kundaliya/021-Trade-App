import 'dart:async';
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
  static const _defaultWatchlistId = 'watchlist_default';
  static const _maximumUserWatchlists = 4;
  static const _maximumNameLength = 30;

  final KeyValueStorage _storage;
  final StreamController<void> _watchlistChanges =
      StreamController<void>.broadcast(sync: true);

  @override
  Stream<void> get watchlistChanges => _watchlistChanges.stream;

  @override
  Future<List<WatchlistDto>> getWatchlists() async {
    await Future<void>.delayed(_requestDelay);
    try {
      final source = await _storage.getString(_storageKey);
      if (source == null || source.trim().isEmpty) {
        return List<WatchlistDto>.unmodifiable(<WatchlistDto>[
          _buildDefaultWatchlist(const <String>[]),
        ]);
      }
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic> || decoded['watchlists'] is! List) {
        throw const FormatException('Invalid watchlist document.');
      }
      final defaultFundIds = _parseFundIds(decoded['defaultFundIds']);
      final defaultName = _parseDefaultName(decoded['defaultName']);
      final userWatchlists = (decoded['watchlists'] as List)
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const FormatException('Invalid watchlist entry.');
            }
            return WatchlistDto.fromJson(value);
          })
          .where((watchlist) => watchlist.id != _defaultWatchlistId)
          .toList(growable: false);
      _validateUserWatchlists(userWatchlists);
      _validateUniqueNames(defaultName, userWatchlists);
      return List<WatchlistDto>.unmodifiable(<WatchlistDto>[
        _buildDefaultWatchlist(defaultFundIds, name: defaultName),
        ...userWatchlists,
      ]);
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
      final defaultWatchlists = watchlists.where(
        (watchlist) => watchlist.id == _defaultWatchlistId,
      );
      if (defaultWatchlists.length != 1) {
        throw const WatchlistDataException(
          'Exactly one Default watchlist is required.',
        );
      }
      final defaultWatchlist = defaultWatchlists.single;
      final userWatchlists = watchlists
          .where((watchlist) => watchlist.id != _defaultWatchlistId)
          .toList(growable: false);
      _validateFundIds(defaultWatchlist.fundIds);
      _validateUserWatchlists(userWatchlists);
      final defaultName = _validateName(defaultWatchlist.name);
      _validateUniqueNames(defaultName, userWatchlists);
      await _persist(
        defaultName: defaultName,
        defaultFundIds: defaultWatchlist.fundIds,
        userWatchlists: userWatchlists,
      );
      _watchlistChanges.add(null);
    } on WatchlistDataException {
      rethrow;
    } on Object catch (error) {
      throw WatchlistDataException('Unable to save watchlists.', error);
    }
  }

  Future<void> _persist({
    required String defaultName,
    required List<String> defaultFundIds,
    required List<WatchlistDto> userWatchlists,
  }) => _storage.setString(
    _storageKey,
    jsonEncode(<String, dynamic>{
      'defaultName': defaultName,
      'defaultFundIds': defaultFundIds,
      'watchlists': userWatchlists.map((item) => item.toJson()).toList(),
    }),
  );

  static void _validateUserWatchlists(List<WatchlistDto> watchlists) {
    if (watchlists.length > _maximumUserWatchlists) {
      throw const WatchlistDataException(
        'A maximum of 4 user-created watchlists is allowed.',
      );
    }
    final ids = <String>{};
    final names = <String>{};
    for (final watchlist in watchlists) {
      final normalizedName = _validateName(watchlist.name).toLowerCase();
      if (watchlist.id == _defaultWatchlistId ||
          watchlist.id.trim().isEmpty ||
          normalizedName.isEmpty) {
        throw const WatchlistDataException(
          'Watchlist IDs and names are required.',
        );
      }
      if (!ids.add(watchlist.id) || !names.add(normalizedName)) {
        throw const WatchlistDataException(
          'Watchlist IDs and names must be unique.',
        );
      }
      _validateFundIds(watchlist.fundIds);
    }
  }

  static String _parseDefaultName(Object? value) {
    if (value == null) return 'Default';
    if (value is! String) {
      throw const FormatException('Invalid Default watchlist name.');
    }
    return _validateName(value);
  }

  static String _validateName(String value) {
    final name = value.trim();
    if (name.isEmpty || name.length > _maximumNameLength) {
      throw const WatchlistDataException(
        'Watchlist names must contain between 1 and 30 characters.',
      );
    }
    return name;
  }

  static void _validateUniqueNames(
    String defaultName,
    List<WatchlistDto> userWatchlists,
  ) {
    final names = <String>{defaultName.toLowerCase()};
    for (final watchlist in userWatchlists) {
      if (!names.add(watchlist.name.trim().toLowerCase())) {
        throw const WatchlistDataException('Watchlist names must be unique.');
      }
    }
  }

  static List<String> _parseFundIds(Object? value) {
    if (value == null) return const <String>[];
    if (value is! List ||
        value.any((id) => id is! String || id.trim().isEmpty)) {
      throw const FormatException('Invalid default fund IDs.');
    }
    final fundIds = value.cast<String>();
    _validateFundIds(fundIds);
    return List<String>.unmodifiable(fundIds);
  }

  static void _validateFundIds(List<String> fundIds) {
    if (fundIds.any((id) => id.trim().isEmpty) ||
        fundIds.toSet().length != fundIds.length) {
      throw const WatchlistDataException(
        'Fund IDs must be non-empty and unique per watchlist.',
      );
    }
  }

  static WatchlistDto _buildDefaultWatchlist(
    List<String> fundIds, {
    String name = 'Default',
  }) {
    final now = DateTime.now();
    return WatchlistDto(
      id: _defaultWatchlistId,
      name: name,
      fundIds: fundIds,
      createdAt: now,
      updatedAt: now,
    );
  }
}
