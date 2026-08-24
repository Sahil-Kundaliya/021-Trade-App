import 'package:flutter/material.dart';

import '../formatters/financial_formatter.dart';
import 'extensions/app_colors.dart';

enum HeatMapTone {
  neutral,
  positiveLow,
  positiveMedium,
  positiveHigh,
  negativeLow,
  negativeMedium,
  negativeHigh,
}

@immutable
final class HeatMapSwatch {
  const HeatMapSwatch({
    required this.fill,
    required this.onFill,
    required this.tone,
  });

  final Color fill;
  final Color onFill;
  final HeatMapTone tone;

  @override
  bool operator ==(Object other) =>
      other is HeatMapSwatch &&
      other.fill == fill &&
      other.onFill == onFill &&
      other.tone == tone;

  @override
  int get hashCode => Object.hash(fill, onFill, tone);
}

/// Resolves heatmap fills from daily change % using [AppColors] semantic roles.
///
/// Intensity uses discrete bands so Dashboard never picks [Color]s itself:
/// 0.00% → neutral; ≤0.50% low; ≤1.50% medium; above that high.
abstract final class HeatMapColorResolver {
  static const double intensityMax = 3;

  static HeatMapSwatch resolve(
    AppColors colors,
    double changePercent, {
    bool hideMovement = false,
  }) {
    if (hideMovement) {
      return HeatMapSwatch(
        fill: colors.heatMapNeutral,
        onFill: colors.onHeatMapNeutral,
        tone: HeatMapTone.neutral,
      );
    }

    final percent = FinancialFormatter.normalize(changePercent);
    final sign = FinancialFormatter.displaySign(percent, percent);
    if (sign == 0) {
      return HeatMapSwatch(
        fill: colors.heatMapNeutral,
        onFill: colors.onHeatMapNeutral,
        tone: HeatMapTone.neutral,
      );
    }

    final intensity = (percent.abs() / intensityMax).clamp(0.0, 1.0);
    final band = intensity <= (0.5 / intensityMax)
        ? 0
        : intensity <= (1.5 / intensityMax)
        ? 1
        : 2;

    if (sign > 0) {
      return switch (band) {
        0 => HeatMapSwatch(
          fill: colors.heatMapPositiveLow,
          onFill: colors.onHeatMapPositiveLow,
          tone: HeatMapTone.positiveLow,
        ),
        1 => HeatMapSwatch(
          fill: colors.heatMapPositiveMedium,
          onFill: colors.onHeatMapPositiveMedium,
          tone: HeatMapTone.positiveMedium,
        ),
        _ => HeatMapSwatch(
          fill: colors.heatMapPositiveHigh,
          onFill: colors.onHeatMapPositiveHigh,
          tone: HeatMapTone.positiveHigh,
        ),
      };
    }

    return switch (band) {
      0 => HeatMapSwatch(
        fill: colors.heatMapNegativeLow,
        onFill: colors.onHeatMapNegativeLow,
        tone: HeatMapTone.negativeLow,
      ),
      1 => HeatMapSwatch(
        fill: colors.heatMapNegativeMedium,
        onFill: colors.onHeatMapNegativeMedium,
        tone: HeatMapTone.negativeMedium,
      ),
      _ => HeatMapSwatch(
        fill: colors.heatMapNegativeHigh,
        onFill: colors.onHeatMapNegativeHigh,
        tone: HeatMapTone.negativeHigh,
      ),
    };
  }
}

extension HeatMapColors on AppColors {
  HeatMapSwatch heatMapSwatch(
    double changePercent, {
    bool hideMovement = false,
  }) => HeatMapColorResolver.resolve(
    this,
    changePercent,
    hideMovement: hideMovement,
  );
}
