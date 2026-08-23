import 'package:flutter/widgets.dart';

class PrivacyModeScope extends InheritedWidget {
  const PrivacyModeScope({
    required this.enabled,
    required super.child,
    super.key,
  });

  final bool enabled;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PrivacyModeScope>()?.enabled ??
      false;

  @override
  bool updateShouldNotify(PrivacyModeScope oldWidget) =>
      enabled != oldWidget.enabled;
}
