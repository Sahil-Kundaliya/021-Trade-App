import 'package:flutter/widgets.dart';
import 'package:navigation_contract/navigation_contract.dart';

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    required this.navigator,
    required super.child,
    super.key,
  });

  final AppNavigator navigator;

  static AppNavigator of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppNavigationScope>();
    assert(scope != null, 'No AppNavigationScope found in the widget tree.');
    return scope!.navigator;
  }

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) {
    return navigator != oldWidget.navigator;
  }
}
