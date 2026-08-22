import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';

@InjectableInit(
  asExtension: false,
  initializerName: 'configureCoreDataDependencies',
)
void registerCoreDataDependencies(GetIt getIt) {
  configureCoreDataDependencies(getIt);
}
