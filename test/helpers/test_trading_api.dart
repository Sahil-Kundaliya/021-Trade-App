import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';

Future<void> installImmediateTradingApi() async {
  configureDependencies();
  final delayedApi = getIt<TradingLocalApi>();
  final results = await Future.wait<Object>([
    delayedApi.getFunds(),
    delayedApi.getHoldings(),
    delayedApi.getMarketIndices(),
  ]);
  await getIt.unregister<TradingLocalApi>();
  getIt.registerSingleton<TradingLocalApi>(
    _ImmediateTradingApi(
      results[0] as List<FundDto>,
      results[1] as List<HoldingDto>,
      results[2] as List<MarketIndexDto>,
    ),
  );
  if (getIt.isRegistered<WatchlistLocalApi>()) {
    await getIt.unregister<WatchlistLocalApi>();
  }
  getIt.registerSingleton<WatchlistLocalApi>(_ImmediateWatchlistApi());
  if (getIt.isRegistered<OrderBookLocalApi>()) {
    await getIt.unregister<OrderBookLocalApi>();
  }
  getIt.registerSingleton<OrderBookLocalApi>(const _ImmediateOrderBookApi());
  if (getIt.isRegistered<AccountFundsLocalApi>()) {
    await getIt.unregister<AccountFundsLocalApi>();
  }
  getIt.registerSingleton<AccountFundsLocalApi>(
    AccountFundsLocalApiImpl.forTests(_MemoryKeyValueStorage()),
  );
  if (getIt.isRegistered<ConnectivityService>()) {
    await getIt.unregister<ConnectivityService>();
  }
  getIt.registerSingleton<ConnectivityService>(
    const _OnlineConnectivityService(),
  );
}

final class _OnlineConnectivityService implements ConnectivityService {
  const _OnlineConnectivityService();

  @override
  Stream<ConnectivityStatus> get statusStream => const Stream.empty();

  @override
  Future<ConnectivityStatus> checkNow() async => ConnectivityStatus.online;

  @override
  Future<void> dispose() async {}
}

final class _ImmediateOrderBookApi implements OrderBookLocalApi {
  const _ImmediateOrderBookApi();

  @override
  Future<List<OrderDto>> getOrders() async => const [];

  @override
  Future<void> saveOrders(List<OrderDto> orders) async {}
}

final class _ImmediateTradingApi implements TradingLocalApi {
  const _ImmediateTradingApi(this._funds, this._holdings, this._indices);

  final List<FundDto> _funds;
  final List<HoldingDto> _holdings;
  final List<MarketIndexDto> _indices;

  @override
  Future<List<FundDto>> getFunds() async => _funds;

  @override
  Future<List<HoldingDto>> getHoldings() async => _holdings;

  @override
  Future<List<MarketIndexDto>> getMarketIndices() async => _indices;
}

final class _ImmediateWatchlistApi implements WatchlistLocalApi {
  _ImmediateWatchlistApi() : _watchlists = _defaults();

  List<WatchlistDto> _watchlists;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  @override
  Stream<void> get watchlistChanges => _changes.stream;

  @override
  Future<List<WatchlistDto>> getWatchlists() async =>
      List<WatchlistDto>.unmodifiable(_watchlists);

  @override
  Future<void> saveWatchlists(List<WatchlistDto> watchlists) async {
    _watchlists = List<WatchlistDto>.unmodifiable(watchlists);
    _changes.add(null);
  }

  static List<WatchlistDto> _defaults() {
    final now = DateTime(2026, 8, 22);
    return <WatchlistDto>[
      WatchlistDto(
        id: 'watchlist_default',
        name: 'Default',
        fundIds: const [
          'RELIANCE_EQ',
          'TCS_EQ',
          'INFY_EQ',
          'HDFCBANK_EQ',
          'ICICIBANK_EQ',
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

final class _MemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
