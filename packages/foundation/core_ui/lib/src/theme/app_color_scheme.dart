import 'package:flutter/material.dart';

import 'extensions/app_colors.dart';

abstract final class AppColorScheme {
  static ColorScheme from(AppColors colors, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.info,
      onSecondary: colors.textInverse,
      secondaryContainer: colors.infoContainer,
      onSecondaryContainer: colors.textPrimary,
      error: colors.negative,
      onError: colors.textInverse,
      errorContainer: colors.negativeContainer,
      onErrorContainer: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.surfaceLow,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.surfaceHigh,
      surfaceContainerHighest: colors.surfaceElevated,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.textInverse,
      inversePrimary: colors.primaryContainer,
      surfaceTint: colors.primary,
      scrim: const Color(0x99000000),
    );
  }

  static final ColorScheme light = from(lightAppColors, Brightness.light);
  static final ColorScheme dark = from(darkAppColors, Brightness.dark);
}
