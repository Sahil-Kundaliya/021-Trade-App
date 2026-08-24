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
    test('compact semantic typography stays within the trading scale', () {
      final styles = AppTheme.light.extension<AppTextStyles>()!;

      expect(styles.pageTitle.fontSize, 20);
      expect(styles.financialHero.fontSize, 22);
      expect(styles.cardTitle.fontSize, 14);
      expect(styles.body.fontSize, 13);
      expect(styles.bodySecondary.fontSize, 12);
      expect(styles.caption.fontSize, 11);
      expect(styles.tableCell.fontFeatures, isNotEmpty);
      expect(styles.financialRegular.fontFeatures, isNotEmpty);
    });

    test('compact sizing and motion tokens preserve accessible targets', () {
      expect(AppSizes.iconTiny, 14);
      expect(AppSizes.buttonHeightMd, 44);
      expect(AppSizes.inputHeight, 44);
      expect(AppSizes.touchTarget, 48);
      expect(AppSizes.heatMapMinHeight, 220);
      expect(AppSizes.heatMapMaxHeight, 320);
      expect(AppSpacing.cardPadding, const EdgeInsets.all(AppSpacing.md));
      expect(AppRadius.md, 8);
      expect(AppBorders.strong, 1.5);
      expect(AppMotion.fast, const Duration(milliseconds: 120));
      expect(AppMotion.standard, const Duration(milliseconds: 200));
    });

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
      expect(
        lightAppColors.heatMapPositiveHigh,
        isNot(darkAppColors.heatMapPositiveHigh),
      );
      expect(
        lightAppColors.copyWith(heatMapNeutral: replacement).heatMapNeutral,
        replacement,
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

  group('HeatMapColorResolver', () {
    test('maps daily change percent to semantic intensity bands', () {
      expect(
        HeatMapColorResolver.resolve(lightAppColors, 0).tone,
        HeatMapTone.neutral,
      );
      expect(
        HeatMapColorResolver.resolve(lightAppColors, 1).tone,
        HeatMapTone.positiveMedium,
      );
      expect(
        HeatMapColorResolver.resolve(lightAppColors, -1).tone,
        HeatMapTone.negativeMedium,
      );
      final low = HeatMapColorResolver.resolve(lightAppColors, 0.2);
      final high = HeatMapColorResolver.resolve(lightAppColors, 2);
      expect(low.tone, HeatMapTone.positiveLow);
      expect(high.tone, HeatMapTone.positiveHigh);
      expect(low.fill, isNot(high.fill));
      final weakLoss = HeatMapColorResolver.resolve(lightAppColors, -0.2);
      final strongLoss = HeatMapColorResolver.resolve(lightAppColors, -2);
      expect(weakLoss.tone, HeatMapTone.negativeLow);
      expect(strongLoss.tone, HeatMapTone.negativeHigh);
      expect(weakLoss.fill, isNot(strongLoss.fill));
    });

    test('light and dark heat map palettes stay distinct', () {
      expect(
        HeatMapColorResolver.resolve(lightAppColors, 2).fill,
        isNot(HeatMapColorResolver.resolve(darkAppColors, 2).fill),
      );
      expect(
        HeatMapColorResolver.resolve(lightAppColors, -2).fill,
        isNot(HeatMapColorResolver.resolve(darkAppColors, -2).fill),
      );
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
