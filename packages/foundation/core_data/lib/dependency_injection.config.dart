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
import 'package:core_data/src/connectivity/connectivity_service.dart' as _i208;
import 'package:core_data/src/connectivity/connectivity_service_impl.dart'
    as _i909;
import 'package:core_data/src/live_price/platform/live_price_platform_api.dart'
    as _i846;
import 'package:core_data/src/live_price/platform/live_price_platform_api_impl.dart'
    as _i578;
import 'package:core_data/src/live_price/stream/live_price_stream_manager.dart'
    as _i951;
import 'package:core_data/src/notifications/local_notification_service.dart'
    as _i993;
import 'package:core_data/src/notifications/local_notification_service_impl.dart'
    as _i514;
import 'package:core_data/src/notifications/trading_notification_coordinator.dart'
    as _i485;
import 'package:core_data/src/order_execution/order_execution_engine.dart'
    as _i51;
import 'package:core_data/src/orderbook/api/orderbook_local_api.dart' as _i871;
import 'package:core_data/src/orderbook/api/orderbook_local_api_impl.dart'
    as _i196;
import 'package:core_data/src/orderbook/store/order_store.dart' as _i32;
import 'package:core_data/src/positions/position_service.dart' as _i21;
import 'package:core_data/src/preferences/api/app_preferences_local_api.dart'
    as _i464;
import 'package:core_data/src/preferences/api/app_preferences_local_api_impl.dart'
    as _i99;
import 'package:core_data/src/preferences/repositories/app_preferences_repository.dart'
    as _i376;
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
  gh.lazySingleton<_i993.LocalNotificationService>(
    () => _i514.LocalNotificationServiceImpl(),
  );
  gh.lazySingleton<_i208.ConnectivityService>(
    () => _i909.ConnectivityServiceImpl(),
    dispose: (i) => i.dispose(),
  );
  gh.lazySingleton<_i767.KeyValueStorage>(
    () => const _i572.FlutterKeyValueStorage(),
  );
  gh.lazySingleton<_i846.LivePricePlatformApi>(
    () => const _i578.LivePricePlatformApiImpl(),
  );
  gh.lazySingleton<_i414.TradingLocalApi>(() => _i125.TradingLocalApiImpl());
  gh.lazySingleton<_i951.LivePriceStreamManager>(
    () => _i951.LivePriceStreamManager(gh<_i846.LivePricePlatformApi>()),
  );
  gh.lazySingleton<_i871.OrderBookLocalApi>(
    () => _i196.OrderBookLocalApiImpl(gh<_i767.KeyValueStorage>()),
  );
  gh.lazySingleton<_i936.WatchlistLocalApi>(
    () => _i668.WatchlistLocalApiImpl(gh<_i767.KeyValueStorage>()),
  );
  gh.lazySingleton<_i464.AppPreferencesLocalApi>(
    () => _i99.AppPreferencesLocalApiImpl(gh<_i767.KeyValueStorage>()),
  );
  gh.lazySingleton<_i376.AppPreferencesRepository>(
    () => _i376.AppPreferencesRepository(gh<_i464.AppPreferencesLocalApi>()),
  );
  gh.lazySingleton<_i32.OrderStore>(
    () => _i32.OrderStore(gh<_i871.OrderBookLocalApi>()),
  );
  gh.lazySingleton<_i485.TradingNotificationCoordinator>(
    () => _i485.TradingNotificationCoordinator(
      gh<_i993.LocalNotificationService>(),
      gh<_i376.AppPreferencesRepository>(),
      gh<_i32.OrderStore>(),
    ),
  );
  gh.lazySingleton<_i21.PositionService>(
    () => _i21.PositionServiceImpl(
      gh<_i32.OrderStore>(),
      gh<_i414.TradingLocalApi>(),
    ),
  );
  gh.lazySingleton<_i51.OrderExecutionEngine>(
    () => _i51.OrderExecutionEngine(
      gh<_i32.OrderStore>(),
      gh<_i951.LivePriceStreamManager>(),
      gh<_i414.TradingLocalApi>(),
      gh<_i21.PositionService>(),
    ),
  );
  return getIt;
}
