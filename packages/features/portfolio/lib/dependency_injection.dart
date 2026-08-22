import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';

@InjectableInit(
  asExtension: false,
  initializerName: 'configurePortfolioDependencies',
)
void registerPortfolioDependencies(GetIt getIt) {
  configurePortfolioDependencies(getIt);
}
