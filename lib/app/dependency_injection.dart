import 'package:core_data/core_data.dart';
import 'package:core_data/dependency_injection.dart';
import 'package:dashboard/dependency_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:fund/dependency_injection.dart';
import 'package:portfolio/dependency_injection.dart';
import 'package:profile/dependency_injection.dart';
import 'package:orderbook/dependency_injection.dart';
import 'package:orders/dependency_injection.dart';
import 'package:watchlist/dependency_injection.dart';
import 'package:zero_two_one_trade_assignment/app/theme/theme_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/preferences/app_preferences_bloc.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<TradingLocalApi>()) return;
  registerCoreDataDependencies(getIt);
  registerDashboardDependencies(getIt);
  registerFundDependencies(getIt);
  registerPortfolioDependencies(getIt);
  registerProfileDependencies(getIt);
  registerOrderBookDependencies(getIt);
  registerOrdersDependencies(getIt);
  registerWatchlistDependencies(getIt);
  getIt.registerFactory<ThemeBloc>(
    () => ThemeBloc(getIt<AppPreferencesRepository>()),
  );
  getIt.registerFactory<AppPreferencesBloc>(
    () => AppPreferencesBloc(
      getIt<AppPreferencesRepository>(),
      getIt<LocalNotificationService>(),
    ),
  );
}
