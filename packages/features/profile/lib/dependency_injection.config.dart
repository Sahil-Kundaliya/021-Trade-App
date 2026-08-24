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
import 'package:profile/src/account/data/repositories/profile_funds_repository_impl.dart'
    as _i166;
import 'package:profile/src/account/data/repositories/profile_preferences_repository_impl.dart'
    as _i264;
import 'package:profile/src/account/domain/repositories/profile_funds_repository.dart'
    as _i591;
import 'package:profile/src/account/domain/repositories/profile_preferences_repository.dart'
    as _i425;
import 'package:profile/src/account/presentation/bloc/profile_bloc.dart'
    as _i397;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureProfileDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i591.ProfileFundsRepository>(
    () => _i166.ProfileFundsRepositoryImpl(gh<_i607.AccountFundsLocalApi>()),
  );
  gh.lazySingleton<_i425.ProfilePreferencesRepository>(
    () => _i264.ProfilePreferencesRepositoryImpl(
      gh<_i607.AppPreferencesRepository>(),
    ),
  );
  gh.factory<_i397.ProfileBloc>(
    () => _i397.ProfileBloc(
      gh<_i425.ProfilePreferencesRepository>(),
      gh<_i591.ProfileFundsRepository>(),
    ),
  );
  return getIt;
}
