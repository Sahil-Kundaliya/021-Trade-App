import 'package:flutter/material.dart';

@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceLow,
    required this.surfaceContainer,
    required this.surfaceHigh,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.positive,
    required this.positiveStrong,
    required this.positiveContainer,
    required this.negative,
    required this.negativeStrong,
    required this.negativeContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.priceUp,
    required this.priceDown,
    required this.priceUpFlash,
    required this.priceDownFlash,
    required this.buy,
    required this.sell,
    required this.buyContainer,
    required this.sellContainer,
    required this.chartGrid,
    required this.chartAxis,
    required this.selection,
    required this.selectionContainer,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.heatMapNeutral,
    required this.heatMapPositiveLow,
    required this.heatMapPositiveMedium,
    required this.heatMapPositiveHigh,
    required this.heatMapNegativeLow,
    required this.heatMapNegativeMedium,
    required this.heatMapNegativeHigh,
    required this.onHeatMapNeutral,
    required this.onHeatMapPositiveLow,
    required this.onHeatMapPositiveMedium,
    required this.onHeatMapPositiveHigh,
    required this.onHeatMapNegativeLow,
    required this.onHeatMapNegativeMedium,
    required this.onHeatMapNegativeHigh,
  });

  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceLow;
  final Color surfaceContainer;
  final Color surfaceHigh;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textInverse;
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final Color positive;
  final Color positiveStrong;
  final Color positiveContainer;
  final Color negative;
  final Color negativeStrong;
  final Color negativeContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color priceUp;
  final Color priceDown;
  final Color priceUpFlash;
  final Color priceDownFlash;
  final Color buy;
  final Color sell;
  final Color buyContainer;
  final Color sellContainer;
  final Color chartGrid;
  final Color chartAxis;
  final Color selection;
  final Color selectionContainer;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color heatMapNeutral;
  final Color heatMapPositiveLow;
  final Color heatMapPositiveMedium;
  final Color heatMapPositiveHigh;
  final Color heatMapNegativeLow;
  final Color heatMapNegativeMedium;
  final Color heatMapNegativeHigh;
  final Color onHeatMapNeutral;
  final Color onHeatMapPositiveLow;
  final Color onHeatMapPositiveMedium;
  final Color onHeatMapPositiveHigh;
  final Color onHeatMapNegativeLow;
  final Color onHeatMapNegativeMedium;
  final Color onHeatMapNegativeHigh;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceLow,
    Color? surfaceContainer,
    Color? surfaceHigh,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? border,
    Color? borderSubtle,
    Color? divider,
    Color? positive,
    Color? positiveStrong,
    Color? positiveContainer,
    Color? negative,
    Color? negativeStrong,
    Color? negativeContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? priceUp,
    Color? priceDown,
    Color? priceUpFlash,
    Color? priceDownFlash,
    Color? buy,
    Color? sell,
    Color? buyContainer,
    Color? sellContainer,
    Color? chartGrid,
    Color? chartAxis,
    Color? selection,
    Color? selectionContainer,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? heatMapNeutral,
    Color? heatMapPositiveLow,
    Color? heatMapPositiveMedium,
    Color? heatMapPositiveHigh,
    Color? heatMapNegativeLow,
    Color? heatMapNegativeMedium,
    Color? heatMapNegativeHigh,
    Color? onHeatMapNeutral,
    Color? onHeatMapPositiveLow,
    Color? onHeatMapPositiveMedium,
    Color? onHeatMapPositiveHigh,
    Color? onHeatMapNegativeLow,
    Color? onHeatMapNegativeMedium,
    Color? onHeatMapNegativeHigh,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      divider: divider ?? this.divider,
      positive: positive ?? this.positive,
      positiveStrong: positiveStrong ?? this.positiveStrong,
      positiveContainer: positiveContainer ?? this.positiveContainer,
      negative: negative ?? this.negative,
      negativeStrong: negativeStrong ?? this.negativeStrong,
      negativeContainer: negativeContainer ?? this.negativeContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      priceUp: priceUp ?? this.priceUp,
      priceDown: priceDown ?? this.priceDown,
      priceUpFlash: priceUpFlash ?? this.priceUpFlash,
      priceDownFlash: priceDownFlash ?? this.priceDownFlash,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      buyContainer: buyContainer ?? this.buyContainer,
      sellContainer: sellContainer ?? this.sellContainer,
      chartGrid: chartGrid ?? this.chartGrid,
      chartAxis: chartAxis ?? this.chartAxis,
      selection: selection ?? this.selection,
      selectionContainer: selectionContainer ?? this.selectionContainer,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      heatMapNeutral: heatMapNeutral ?? this.heatMapNeutral,
      heatMapPositiveLow: heatMapPositiveLow ?? this.heatMapPositiveLow,
      heatMapPositiveMedium:
          heatMapPositiveMedium ?? this.heatMapPositiveMedium,
      heatMapPositiveHigh: heatMapPositiveHigh ?? this.heatMapPositiveHigh,
      heatMapNegativeLow: heatMapNegativeLow ?? this.heatMapNegativeLow,
      heatMapNegativeMedium:
          heatMapNegativeMedium ?? this.heatMapNegativeMedium,
      heatMapNegativeHigh: heatMapNegativeHigh ?? this.heatMapNegativeHigh,
      onHeatMapNeutral: onHeatMapNeutral ?? this.onHeatMapNeutral,
      onHeatMapPositiveLow: onHeatMapPositiveLow ?? this.onHeatMapPositiveLow,
      onHeatMapPositiveMedium:
          onHeatMapPositiveMedium ?? this.onHeatMapPositiveMedium,
      onHeatMapPositiveHigh:
          onHeatMapPositiveHigh ?? this.onHeatMapPositiveHigh,
      onHeatMapNegativeLow: onHeatMapNegativeLow ?? this.onHeatMapNegativeLow,
      onHeatMapNegativeMedium:
          onHeatMapNegativeMedium ?? this.onHeatMapNegativeMedium,
      onHeatMapNegativeHigh:
          onHeatMapNegativeHigh ?? this.onHeatMapNegativeHigh,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveStrong: Color.lerp(positiveStrong, other.positiveStrong, t)!,
      positiveContainer: Color.lerp(
        positiveContainer,
        other.positiveContainer,
        t,
      )!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeStrong: Color.lerp(negativeStrong, other.negativeStrong, t)!,
      negativeContainer: Color.lerp(
        negativeContainer,
        other.negativeContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      priceUp: Color.lerp(priceUp, other.priceUp, t)!,
      priceDown: Color.lerp(priceDown, other.priceDown, t)!,
      priceUpFlash: Color.lerp(priceUpFlash, other.priceUpFlash, t)!,
      priceDownFlash: Color.lerp(priceDownFlash, other.priceDownFlash, t)!,
      buy: Color.lerp(buy, other.buy, t)!,
      sell: Color.lerp(sell, other.sell, t)!,
      buyContainer: Color.lerp(buyContainer, other.buyContainer, t)!,
      sellContainer: Color.lerp(sellContainer, other.sellContainer, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      chartAxis: Color.lerp(chartAxis, other.chartAxis, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      selectionContainer: Color.lerp(
        selectionContainer,
        other.selectionContainer,
        t,
      )!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      heatMapNeutral: Color.lerp(heatMapNeutral, other.heatMapNeutral, t)!,
      heatMapPositiveLow: Color.lerp(
        heatMapPositiveLow,
        other.heatMapPositiveLow,
        t,
      )!,
      heatMapPositiveMedium: Color.lerp(
        heatMapPositiveMedium,
        other.heatMapPositiveMedium,
        t,
      )!,
      heatMapPositiveHigh: Color.lerp(
        heatMapPositiveHigh,
        other.heatMapPositiveHigh,
        t,
      )!,
      heatMapNegativeLow: Color.lerp(
        heatMapNegativeLow,
        other.heatMapNegativeLow,
        t,
      )!,
      heatMapNegativeMedium: Color.lerp(
        heatMapNegativeMedium,
        other.heatMapNegativeMedium,
        t,
      )!,
      heatMapNegativeHigh: Color.lerp(
        heatMapNegativeHigh,
        other.heatMapNegativeHigh,
        t,
      )!,
      onHeatMapNeutral: Color.lerp(
        onHeatMapNeutral,
        other.onHeatMapNeutral,
        t,
      )!,
      onHeatMapPositiveLow: Color.lerp(
        onHeatMapPositiveLow,
        other.onHeatMapPositiveLow,
        t,
      )!,
      onHeatMapPositiveMedium: Color.lerp(
        onHeatMapPositiveMedium,
        other.onHeatMapPositiveMedium,
        t,
      )!,
      onHeatMapPositiveHigh: Color.lerp(
        onHeatMapPositiveHigh,
        other.onHeatMapPositiveHigh,
        t,
      )!,
      onHeatMapNegativeLow: Color.lerp(
        onHeatMapNegativeLow,
        other.onHeatMapNegativeLow,
        t,
      )!,
      onHeatMapNegativeMedium: Color.lerp(
        onHeatMapNegativeMedium,
        other.onHeatMapNegativeMedium,
        t,
      )!,
      onHeatMapNegativeHigh: Color.lerp(
        onHeatMapNegativeHigh,
        other.onHeatMapNegativeHigh,
        t,
      )!,
    );
  }
}

const lightAppColors = AppColors(
  primary: Color(0xFF3157F6),
  primaryContainer: Color(0xFFE8EDFF),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryContainer: Color(0xFF18318C),
  background: Color(0xFFF7F9FC),
  surface: Color(0xFFFFFFFF),
  surfaceLow: Color(0xFFF4F6FA),
  surfaceContainer: Color(0xFFEEF2F7),
  surfaceHigh: Color(0xFFE8EDF3),
  surfaceElevated: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF111827),
  textSecondary: Color(0xFF5F6B7A),
  textTertiary: Color(0xFF8A95A5),
  textDisabled: Color(0xFFB5BDC8),
  textInverse: Color(0xFFFFFFFF),
  border: Color(0xFFDDE3EB),
  borderSubtle: Color(0xFFE9EDF2),
  divider: Color(0xFFEDF0F4),
  positive: Color(0xFF158F5B),
  positiveStrong: Color(0xFF087A49),
  positiveContainer: Color(0xFFE7F7EF),
  negative: Color(0xFFD63C3C),
  negativeStrong: Color(0xFFB4232C),
  negativeContainer: Color(0xFFFCEBEC),
  warning: Color(0xFFD98A00),
  warningContainer: Color(0xFFFFF4D6),
  info: Color(0xFF1677C8),
  infoContainer: Color(0xFFE8F3FC),
  priceUp: Color(0xFF158F5B),
  priceDown: Color(0xFFD63C3C),
  priceUpFlash: Color(0xFFE7F7EF),
  priceDownFlash: Color(0xFFFCEBEC),
  buy: Color(0xFF158F5B),
  sell: Color(0xFFD63C3C),
  buyContainer: Color(0xFFE7F7EF),
  sellContainer: Color(0xFFFCEBEC),
  chartGrid: Color(0xFFE9EDF2),
  chartAxis: Color(0xFF8A95A5),
  selection: Color(0xFF3157F6),
  selectionContainer: Color(0xFFE8EDFF),
  skeletonBase: Color(0xFFE4E9F0),
  skeletonHighlight: Color(0xFFF5F7FA),
  heatMapNeutral: Color(0xFFE6EBF1),
  heatMapPositiveLow: Color(0xFFD4F0E2),
  heatMapPositiveMedium: Color(0xFF3EA972),
  heatMapPositiveHigh: Color(0xFF0B6B3C),
  heatMapNegativeLow: Color(0xFFF8DCDC),
  heatMapNegativeMedium: Color(0xFFE05555),
  heatMapNegativeHigh: Color(0xFFA31B22),
  onHeatMapNeutral: Color(0xFF111827),
  onHeatMapPositiveLow: Color(0xFF0D5C38),
  onHeatMapPositiveMedium: Color(0xFFFFFFFF),
  onHeatMapPositiveHigh: Color(0xFFFFFFFF),
  onHeatMapNegativeLow: Color(0xFF8B1E22),
  onHeatMapNegativeMedium: Color(0xFFFFFFFF),
  onHeatMapNegativeHigh: Color(0xFFFFFFFF),
);

const darkAppColors = AppColors(
  primary: Color(0xFF8297FF),
  primaryContainer: Color(0xFF27376F),
  onPrimary: Color(0xFF0C173D),
  onPrimaryContainer: Color(0xFFDDE4FF),
  background: Color(0xFF0B0F14),
  surface: Color(0xFF10151C),
  surfaceLow: Color(0xFF131920),
  surfaceContainer: Color(0xFF171E27),
  surfaceHigh: Color(0xFF1D2631),
  surfaceElevated: Color(0xFF202A35),
  textPrimary: Color(0xFFF4F7FB),
  textSecondary: Color(0xFFAAB4C0),
  textTertiary: Color(0xFF7F8B99),
  textDisabled: Color(0xFF5F6975),
  textInverse: Color(0xFF111827),
  border: Color(0xFF293440),
  borderSubtle: Color(0xFF222C36),
  divider: Color(0xFF1D2630),
  positive: Color(0xFF35C98A),
  positiveStrong: Color(0xFF55DDA0),
  positiveContainer: Color(0xFF12392A),
  negative: Color(0xFFF26B6B),
  negativeStrong: Color(0xFFFF8585),
  negativeContainer: Color(0xFF402024),
  warning: Color(0xFFF0B84B),
  warningContainer: Color(0xFF3D3016),
  info: Color(0xFF5DB4F5),
  infoContainer: Color(0xFF17344A),
  priceUp: Color(0xFF35C98A),
  priceDown: Color(0xFFF26B6B),
  priceUpFlash: Color(0xFF12392A),
  priceDownFlash: Color(0xFF402024),
  buy: Color(0xFF35C98A),
  sell: Color(0xFFF26B6B),
  buyContainer: Color(0xFF12392A),
  sellContainer: Color(0xFF402024),
  chartGrid: Color(0xFF222C36),
  chartAxis: Color(0xFF7F8B99),
  selection: Color(0xFF8297FF),
  selectionContainer: Color(0xFF27376F),
  skeletonBase: Color(0xFF202A35),
  skeletonHighlight: Color(0xFF303C49),
  heatMapNeutral: Color(0xFF1D2631),
  heatMapPositiveLow: Color(0xFF12392A),
  heatMapPositiveMedium: Color(0xFF1A6B45),
  heatMapPositiveHigh: Color(0xFF2ECC7A),
  heatMapNegativeLow: Color(0xFF402024),
  heatMapNegativeMedium: Color(0xFF8E2F35),
  heatMapNegativeHigh: Color(0xFFF26B6B),
  onHeatMapNeutral: Color(0xFFF4F7FB),
  onHeatMapPositiveLow: Color(0xFF8EEBB8),
  onHeatMapPositiveMedium: Color(0xFFE8FFF2),
  onHeatMapPositiveHigh: Color(0xFF0B1F14),
  onHeatMapNegativeLow: Color(0xFFFFB3B3),
  onHeatMapNegativeMedium: Color(0xFFFFE8E8),
  onHeatMapNegativeHigh: Color(0xFF2A1012),
);
