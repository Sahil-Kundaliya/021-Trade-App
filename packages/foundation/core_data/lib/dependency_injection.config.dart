// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core_data/src/cache/flutter_key_value_storage.dart' as _i572;
import 'package:core_data/src/cache/key_value_storage.dart' as _i767;
import 'package:core_data/src/trading/api/trading_local_api.dart' as _i414;
import 'package:core_data/src/trading/api/trading_local_api_impl.dart' as _i125;
import 'package:core_data/src/watchlist/api/watchlist_local_api.dart' as _i936;
import 'package:core_data/src/watchlist/api/watchlist_local_api_impl.dart'
    as _i668;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureCoreDataDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i767.KeyValueStorage>(
    () => const _i572.FlutterKeyValueStorage(),
  );
  gh.lazySingleton<_i414.TradingLocalApi>(() => _i125.TradingLocalApiImpl());
  gh.lazySingleton<_i936.WatchlistLocalApi>(
    () => _i668.WatchlistLocalApiImpl(gh<_i767.KeyValueStorage>()),
  );
  return getIt;
}
