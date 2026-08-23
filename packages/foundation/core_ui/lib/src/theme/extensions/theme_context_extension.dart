import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import '../tokens/app_durations.dart';

extension AppThemeContext on BuildContext {
  AppColors get appColors {
    final colors = Theme.of(this).extension<AppColors>();
    assert(colors != null, 'AppColors ThemeExtension is not registered.');
    return colors!;
  }

  AppTextStyles get appTextStyles {
    final styles = Theme.of(this).extension<AppTextStyles>();
    assert(styles != null, 'AppTextStyles ThemeExtension is not registered.');
    return styles!;
  }

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get animationsDisabled =>
      MediaQuery.maybeOf(this)?.disableAnimations ?? false;

  Duration motionDuration(Duration duration) =>
      animationsDisabled ? AppMotion.instant : duration;
}
