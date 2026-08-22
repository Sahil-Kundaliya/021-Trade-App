import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'extensions/app_colors.dart';
import 'extensions/app_text_styles.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_sizes.dart';
import 'tokens/app_spacing.dart';
import 'typography/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: lightAppColors,
    colorScheme: AppColorScheme.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: darkAppColors,
    colorScheme: AppColorScheme.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
    required ColorScheme colorScheme,
  }) {
    final textTheme = AppTypography.textTheme(
      brightness: brightness,
      textPrimary: colors.textPrimary,
      textSecondary: colors.textSecondary,
    );
    final tradingTextStyles = AppTextStyles.fromTextTheme(textTheme);
    final controlShape = RoundedRectangleBorder(
      borderRadius: AppRadius.smBorderRadius,
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: AppRadius.mdBorderRadius,
      side: BorderSide(color: colors.borderSubtle),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      disabledColor: colors.textDisabled,
      dividerColor: colors.divider,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors, tradingTextStyles],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomNavHeight,
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorColor: colors.selectionContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.selection
                : colors.textTertiary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelSmall!;
          return base.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.selection
                : colors.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.selection,
        unselectedItemColor: colors.textTertiary,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceLow,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textTertiary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.primary,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.negative),
        prefixIconColor: colors.textTertiary,
        suffixIconColor: colors.textTertiary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.negativeStrong, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smBorderRadius,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          elevation: 0,
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.border),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSizes.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          foregroundColor: colors.primary,
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSizes.touchTarget),
          foregroundColor: colors.textSecondary,
          shape: controlShape,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceLow,
        selectedColor: colors.selectionContainer,
        disabledColor: colors.surfaceContainer,
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: colors.selection,
        ),
        side: BorderSide(color: colors.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: colors.surfaceElevated,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorderRadius),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
        surfaceTintColor: colors.surfaceElevated,
        elevation: 8,
        modalElevation: 8,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textInverse,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xsBorderRadius),
        side: BorderSide(color: colors.border, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.textTertiary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.textDisabled;
          }
          return states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.surfaceContainer;
          }
          return states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceHigh;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.textPrimary,
          borderRadius: AppRadius.xsBorderRadius,
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: colors.textInverse),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceContainer,
        circularTrackColor: colors.surfaceContainer,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(colors.border),
        trackColor: WidgetStatePropertyAll(colors.surfaceLow),
        radius: const Radius.circular(AppRadius.pill),
        thickness: const WidgetStatePropertyAll(4),
      ),
    );
  }
}
