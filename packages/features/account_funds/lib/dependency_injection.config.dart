// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:account_funds/src/add_funds/data/repositories/account_funds_repository_impl.dart'
    as _i239;
import 'package:account_funds/src/add_funds/domain/repositories/account_funds_repository.dart'
    as _i127;
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_bloc.dart'
    as _i13;
import 'package:core_data/core_data.dart' as _i607;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureAccountFundsDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i127.AccountFundsRepository>(
    () => _i239.AccountFundsRepositoryImpl(gh<_i607.AccountFundsLocalApi>()),
  );
  gh.factory<_i13.AccountFundsBloc>(
    () => _i13.AccountFundsBloc(gh<_i127.AccountFundsRepository>()),
  );
  return getIt;
}
