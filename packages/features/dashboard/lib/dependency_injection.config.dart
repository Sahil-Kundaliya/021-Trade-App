// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core_data/core_data.dart' as _i607;
import 'package:dashboard/src/heat_map/data/repositories/heat_map_repository_impl.dart'
    as _i244;
import 'package:dashboard/src/heat_map/domain/repositories/heat_map_repository.dart'
    as _i775;
import 'package:dashboard/src/heat_map/presentation/bloc/market_heat_map_bloc.dart'
    as _i264;
import 'package:dashboard/src/market/data/repositories/market_repository_impl.dart'
    as _i189;
import 'package:dashboard/src/market/domain/repositories/market_repository.dart'
    as _i126;
import 'package:dashboard/src/market/presentation/bloc/market_bloc.dart'
    as _i338;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureDashboardDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i126.MarketRepository>(
    () => _i189.MarketRepositoryImpl(gh<_i607.TradingLocalApi>()),
  );
  gh.lazySingleton<_i775.HeatMapRepository>(
    () => _i244.HeatMapRepositoryImpl(gh<_i607.TradingLocalApi>()),
  );
  gh.factory<_i338.MarketBloc>(
    () => _i338.MarketBloc(
      gh<_i126.MarketRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  gh.factory<_i264.MarketHeatMapBloc>(
    () => _i264.MarketHeatMapBloc(
      gh<_i775.HeatMapRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
