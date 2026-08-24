import 'package:flutter/material.dart';

import '../../formatters/financial_formatter.dart';
import '../../privacy/sensitive_value_text.dart';
import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_spacing.dart';
import 'market_price_change.dart';

class MarketQuote extends StatelessWidget {
  const MarketQuote({
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.showDirection = true,
    this.alignment = CrossAxisAlignment.end,
    this.priceStyle,
    this.changeStyle,
    super.key,
  });

  final double ltp;
  final double change;
  final double changePercent;
  final bool showDirection;
  final CrossAxisAlignment alignment;
  final TextStyle? priceStyle;
  final TextStyle? changeStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        SensitiveValueText(
          FinancialFormatter.price(ltp),
          type: SensitiveValueType.currency,
          isMasked: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              priceStyle ??
              context.appTextStyles.priceSmall.copyWith(
                color: context.appColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        MarketPriceChange(
          change: change,
          changePercent: changePercent,
          isMasked: false,
          showDirection: showDirection,
          style: changeStyle,
          textAlign: alignment == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
        ),
      ],
    );
  }
}
