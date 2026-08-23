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
import 'package:orders/src/order_placement/data/repositories/order_placement_repository_impl.dart'
    as _i161;
import 'package:orders/src/order_placement/domain/repositories/order_placement_repository.dart'
    as _i326;
import 'package:orders/src/order_placement/presentation/bloc/order_placement_bloc.dart'
    as _i41;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt configureOrdersDependencies(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i326.OrderPlacementRepository>(
    () => _i161.OrderPlacementRepositoryImpl(
      gh<_i607.TradingLocalApi>(),
      gh<_i607.OrderStore>(),
      gh<_i607.PositionService>(),
    ),
  );
  gh.factory<_i41.OrderPlacementBloc>(
    () => _i41.OrderPlacementBloc(
      gh<_i326.OrderPlacementRepository>(),
      gh<_i607.LivePriceStreamManager>(),
    ),
  );
  return getIt;
}
