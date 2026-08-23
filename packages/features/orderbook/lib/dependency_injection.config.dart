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
import 'package:orderbook/src/orderbook/data/repositories/orderbook_repository_impl.dart'
    as _i24;
import 'package:orderbook/src/orderbook/domain/repositories/orderbook_repository.dart'
    as _i231;
import 'package:orderbook/src/orderbook/presentation/bloc/orderbook_bloc.dart'
    as _i410;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureOrderBookDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i231.OrderBookRepository>(
    () => _i24.OrderBookRepositoryImpl(gh<_i607.OrderStore>()),
  );
  gh.factory<_i410.OrderBookBloc>(
    () => _i410.OrderBookBloc(gh<_i231.OrderBookRepository>()),
  );
  return getIt;
}
