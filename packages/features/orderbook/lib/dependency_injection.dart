import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';

@InjectableInit(
  asExtension: false,
  initializerName: 'configureOrderBookDependencies',
)
void registerOrderBookDependencies(GetIt getIt) {
  configureOrderBookDependencies(getIt);
}
