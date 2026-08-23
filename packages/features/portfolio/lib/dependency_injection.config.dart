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
import 'package:portfolio/src/holdings/data/repositories/holdings_repository_impl.dart'
    as _i530;
import 'package:portfolio/src/holdings/domain/repositories/holdings_repository.dart'
    as _i976;
import 'package:portfolio/src/holdings/presentation/bloc/holdings_bloc.dart'
    as _i485;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configurePortfolioDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i976.HoldingsRepository>(
    () => _i530.HoldingsRepositoryImpl(gh<_i607.PositionService>()),
  );
  gh.factory<_i485.HoldingsBloc>(
    () => _i485.HoldingsBloc(
      gh<_i976.HoldingsRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
