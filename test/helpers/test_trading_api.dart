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
