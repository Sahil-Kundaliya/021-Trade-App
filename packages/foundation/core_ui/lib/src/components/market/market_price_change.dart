import 'package:flutter/material.dart';

import '../../formatters/financial_formatter.dart';
import '../../privacy/sensitive_value_text.dart';
import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_sizes.dart';
import '../../theme/tokens/app_spacing.dart';
import 'market_price_display_scope.dart';

class MarketPriceChange extends StatelessWidget {
  const MarketPriceChange({
    required this.change,
    required this.changePercent,
    this.showDirection = true,
    this.isMasked,
    this.style,
    this.textAlign,
    this.maxLines = 1,
    super.key,
  });

  final double change;
  final double changePercent;
  final bool showDirection;
  final bool? isMasked;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final sign = FinancialFormatter.displaySign(change, changePercent);
    final color = switch (sign) {
      > 0 => context.appColors.positive,
      < 0 => context.appColors.negative,
      _ => context.appColors.textSecondary,
    };
    final textStyle = (style ?? context.appTextStyles.percentageSmall).copyWith(
      color: color,
    );
    final mode = MarketPriceDisplayScope.of(context);
    final label = switch (mode) {
      MarketPriceDisplayMode.absoluteAndPercent =>
        FinancialFormatter.changeGroup(change, changePercent),
      MarketPriceDisplayMode.percentOnly => FinancialFormatter.percentage(
        changePercent,
      ),
      MarketPriceDisplayMode.absoluteOnly => FinancialFormatter.change(change),
    };
    final maskedValue = switch (mode) {
      MarketPriceDisplayMode.absoluteAndPercent =>
        '${PrivacyMask.number} (${PrivacyMask.percentage})',
      MarketPriceDisplayMode.percentOnly => PrivacyMask.percentage,
      MarketPriceDisplayMode.absoluteOnly => PrivacyMask.number,
    };
    final showArrow = showDirection && sign != 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: textAlign == TextAlign.end
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        SensitiveValueText(
          label,
          isMasked: isMasked,
          maskedValue: maskedValue,
          style: textStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (showArrow) ...[
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            sign > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: AppSizes.iconTiny,
            color: color,
          ),
        ],
      ],
    );
  }
}
