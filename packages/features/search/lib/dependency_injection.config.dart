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
import 'package:search/src/fund_search/data/repositories/search_repository_impl.dart'
    as _i117;
import 'package:search/src/fund_search/domain/repositories/search_repository.dart'
    as _i774;
import 'package:search/src/fund_search/presentation/bloc/search_bloc.dart'
    as _i552;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureSearchDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i774.SearchRepository>(
    () => _i117.SearchRepositoryImpl(gh<_i607.TradingLocalApi>()),
  );
  gh.factory<_i552.SearchBloc>(
    () => _i552.SearchBloc(
      gh<_i774.SearchRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
