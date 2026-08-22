import 'package:core_data/core_data.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';

Future<void> installImmediateTradingApi() async {
  configureDependencies();
  final delayedApi = getIt<TradingLocalApi>();
  final results = await Future.wait<Object>([
    delayedApi.getFunds(),
    delayedApi.getHoldings(),
  ]);
  await getIt.unregister<TradingLocalApi>();
  getIt.registerSingleton<TradingLocalApi>(
    _ImmediateTradingApi(
      results[0] as List<FundDto>,
      results[1] as List<HoldingDto>,
    ),
  );
  if (getIt.isRegistered<WatchlistLocalApi>()) {
    await getIt.unregister<WatchlistLocalApi>();
  }
  getIt.registerSingleton<WatchlistLocalApi>(_ImmediateWatchlistApi());
}

final class _ImmediateTradingApi implements TradingLocalApi {
  const _ImmediateTradingApi(this._funds, this._holdings);

  final List<FundDto> _funds;
  final List<HoldingDto> _holdings;

  @override
  Future<List<FundDto>> getFunds() async => _funds;

  @override
  Future<List<HoldingDto>> getHoldings() async => _holdings;
}

final class _ImmediateWatchlistApi implements WatchlistLocalApi {
  _ImmediateWatchlistApi() : _watchlists = _defaults();

  List<WatchlistDto> _watchlists;

  @override
  Future<List<WatchlistDto>> getWatchlists() async =>
      List<WatchlistDto>.unmodifiable(_watchlists);

  @override
  Future<void> saveWatchlists(List<WatchlistDto> watchlists) async {
    _watchlists = List<WatchlistDto>.unmodifiable(watchlists);
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
