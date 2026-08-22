import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('registers and maps light theme extensions', () {
      final theme = AppTheme.light;
      final colors = theme.extension<AppColors>();
      final styles = theme.extension<AppTextStyles>();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(colors, same(lightAppColors));
      expect(styles, isNotNull);
      expect(theme.colorScheme.primary, lightAppColors.primary);
      expect(theme.colorScheme.surface, lightAppColors.surface);
      expect(theme.colorScheme.outline, lightAppColors.border);
      expect(theme.colorScheme.error, lightAppColors.negative);
      expect(theme.scaffoldBackgroundColor, lightAppColors.background);
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Poppins'));
    });

    test('registers and maps dark theme extensions', () {
      final theme = AppTheme.dark;
      final colors = theme.extension<AppColors>();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(colors, same(darkAppColors));
      expect(theme.colorScheme.primary, darkAppColors.primary);
      expect(theme.colorScheme.surface, darkAppColors.surface);
      expect(theme.colorScheme.outline, darkAppColors.border);
      expect(theme.colorScheme.error, darkAppColors.negative);
      expect(theme.scaffoldBackgroundColor, darkAppColors.background);
    });
  });

  group('Theme extensions', () {
    test('AppColors copyWith and lerp preserve semantic roles', () {
      const replacement = Color(0xFF123456);
      final copied = lightAppColors.copyWith(positive: replacement);
      final midpoint = lightAppColors.lerp(darkAppColors, 0.5);

      expect(copied.positive, replacement);
      expect(copied.negative, lightAppColors.negative);
      expect(
        midpoint.primary,
        Color.lerp(lightAppColors.primary, darkAppColors.primary, 0.5),
      );
      expect(
        midpoint.priceUpFlash,
        Color.lerp(
          lightAppColors.priceUpFlash,
          darkAppColors.priceUpFlash,
          0.5,
        ),
      );
    });

    test('AppTextStyles copyWith and lerp interpolate styles', () {
      final lightStyles = AppTheme.light.extension<AppTextStyles>()!;
      final darkStyles = AppTheme.dark.extension<AppTextStyles>()!;
      final replacement = lightStyles.priceLarge.copyWith(fontSize: 99);
      final copied = lightStyles.copyWith(priceLarge: replacement);
      final midpoint = lightStyles.lerp(darkStyles, 0.5);

      expect(copied.priceLarge.fontSize, 99);
      expect(copied.priceMedium, lightStyles.priceMedium);
      expect(midpoint.priceLarge, isNotNull);
      expect(lightStyles.priceMedium.fontFeatures, isNotEmpty);
    });
  });

  testWidgets('BuildContext exposes the active dark design system', (
    tester,
  ) async {
    late AppColors activeColors;
    late bool isDarkMode;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            activeColors = context.appColors;
            isDarkMode = context.isDarkMode;
            return const Scaffold(body: Text('Theme probe'));
          },
        ),
      ),
    );

    expect(activeColors.background, darkAppColors.background);
    expect(isDarkMode, isTrue);
  });
}
