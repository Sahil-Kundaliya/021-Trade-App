import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HeatMapLegend extends StatelessWidget {
  const HeatMapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final negative = colors.heatMapSwatch(-2);
    final neutral = colors.heatMapSwatch(0);
    final positive = colors.heatMapSwatch(2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(label: 'Up', color: positive.fill),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(label: 'Neutral', color: neutral.fill),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(label: 'Down', color: negative.fill),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.xxs),
      Text(
        label,
        style: context.appTextStyles.caption.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    ],
  );
}
