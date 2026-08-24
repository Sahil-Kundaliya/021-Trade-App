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
    final labelStyle = context.appTextStyles.caption.copyWith(
      color: context.appColors.textSecondary,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.xsBorderRadius,
          child: SizedBox(
            height: AppSpacing.sm,
            child: Row(
              children: [
                Expanded(child: ColoredBox(color: negative.fill)),
                Expanded(child: ColoredBox(color: neutral.fill)),
                Expanded(child: ColoredBox(color: positive.fill)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text('-2%', style: labelStyle),
            const Spacer(),
            Text('0%', style: labelStyle),
            const Spacer(),
            Text('+2%', style: labelStyle),
          ],
        ),
      ],
    );
  }
}
