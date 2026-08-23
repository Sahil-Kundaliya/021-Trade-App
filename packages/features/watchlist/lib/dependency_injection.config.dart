// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core_data/core_data.dart' as _i607;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:watchlist/src/watchlist/data/repositories/watchlist_repository_impl.dart'
    as _i100;
import 'package:watchlist/src/watchlist/domain/repositories/watchlist_repository.dart'
    as _i759;
import 'package:watchlist/src/watchlist/presentation/bloc/watchlist_bloc.dart'
    as _i426;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureWatchlistDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i759.WatchlistRepository>(
    () => _i100.WatchlistRepositoryImpl(
      gh<_i607.WatchlistLocalApi>(),
      gh<_i607.TradingLocalApi>(),
    ),
  );
  gh.factory<_i426.WatchlistBloc>(
    () => _i426.WatchlistBloc(
      gh<_i759.WatchlistRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
