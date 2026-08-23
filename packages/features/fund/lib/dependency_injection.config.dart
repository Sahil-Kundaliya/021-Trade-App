// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:core_data/core_data.dart' as _i607;
import 'package:fund/src/fund_details/data/repositories/fund_repository_impl.dart'
    as _i569;
import 'package:fund/src/fund_details/data/repositories/fund_watchlist_repository_impl.dart'
    as _i141;
import 'package:fund/src/fund_details/domain/repositories/fund_repository.dart'
    as _i987;
import 'package:fund/src/fund_details/domain/repositories/fund_watchlist_repository.dart'
    as _i87;
import 'package:fund/src/fund_details/presentation/bloc/fund_details_bloc.dart'
    as _i1055;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureFundDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i987.FundRepository>(
    () => _i569.FundRepositoryImpl(gh<_i607.TradingLocalApi>()),
  );
  gh.lazySingleton<_i87.FundWatchlistRepository>(
    () => _i141.FundWatchlistRepositoryImpl(gh<_i607.WatchlistLocalApi>()),
  );
  gh.factory<_i1055.FundDetailsBloc>(
    () => _i1055.FundDetailsBloc(
      gh<_i987.FundRepository>(),
      gh<_i87.FundWatchlistRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
