import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme({
    required Brightness brightness,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final base = ThemeData(brightness: brightness).textTheme;
    final poppins = GoogleFonts.poppinsTextTheme(
      base,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary);

    TextStyle style(
      TextStyle? source, {
      required double size,
      required FontWeight weight,
      required double height,
      required double letterSpacing,
      Color? color,
    }) {
      return source!.copyWith(
        color: color ?? textPrimary,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    return poppins.copyWith(
      displayLarge: style(
        poppins.displayLarge,
        size: 40,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: style(
        poppins.displayMedium,
        size: 36,
        weight: FontWeight.w600,
        height: 1.22,
        letterSpacing: -0.4,
      ),
      displaySmall: style(
        poppins.displaySmall,
        size: 32,
        weight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      headlineLarge: style(
        poppins.headlineLarge,
        size: 28,
        weight: FontWeight.w600,
        height: 1.28,
        letterSpacing: -0.2,
      ),
      headlineMedium: style(
        poppins.headlineMedium,
        size: 24,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.15,
      ),
      headlineSmall: style(
        poppins.headlineSmall,
        size: 20,
        weight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.1,
      ),
      titleLarge: style(
        poppins.titleLarge,
        size: 18,
        weight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      ),
      titleMedium: style(
        poppins.titleMedium,
        size: 16,
        weight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      ),
      titleSmall: style(
        poppins.titleSmall,
        size: 14,
        weight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.05,
      ),
      bodyLarge: style(
        poppins.bodyLarge,
        size: 16,
        weight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodyMedium: style(
        poppins.bodyMedium,
        size: 14,
        weight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.05,
      ),
      bodySmall: style(
        poppins.bodySmall,
        size: 12,
        weight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        color: textSecondary,
      ),
      labelLarge: style(
        poppins.labelLarge,
        size: 14,
        weight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: style(
        poppins.labelMedium,
        size: 12,
        weight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.15,
      ),
      labelSmall: style(
        poppins.labelSmall,
        size: 11,
        weight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.2,
        color: textSecondary,
      ),
    );
  }
}
