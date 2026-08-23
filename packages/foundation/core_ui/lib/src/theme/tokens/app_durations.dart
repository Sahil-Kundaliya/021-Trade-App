import 'package:flutter/animation.dart';

/// Shared motion vocabulary for interface transitions only.
abstract final class AppMotion {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration long = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration shimmer = Duration(milliseconds: 1200);
}

abstract final class AppMotionCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutCubic;
}

/// Backwards-compatible names while callers migrate to semantic motion roles.
@Deprecated('Use AppMotion instead.')
abstract final class AppDurations {
  static const Duration instant = AppMotion.instant;
  static const Duration fast = AppMotion.fast;
  static const Duration normal = AppMotion.medium;
  static const Duration slow = AppMotion.slow;
}
