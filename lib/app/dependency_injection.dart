import 'package:core_data/core_data.dart';
import 'package:core_data/dependency_injection.dart';
import 'package:dashboard/dependency_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:fund/dependency_injection.dart';
import 'package:portfolio/dependency_injection.dart';
import 'package:watchlist/dependency_injection.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<TradingLocalApi>()) return;
  registerCoreDataDependencies(getIt);
  registerDashboardDependencies(getIt);
  registerFundDependencies(getIt);
  registerPortfolioDependencies(getIt);
  registerWatchlistDependencies(getIt);
}
