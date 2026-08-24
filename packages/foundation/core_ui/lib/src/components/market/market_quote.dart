import 'package:flutter/material.dart';

import '../../formatters/financial_formatter.dart';
import '../../privacy/sensitive_value_text.dart';
import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_spacing.dart';
import 'market_price_change.dart';
import 'live_value_flash.dart';

class MarketQuote extends StatelessWidget {
  const MarketQuote({
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.showDirection = true,
    this.alignment = CrossAxisAlignment.end,
    this.priceStyle,
    this.changeStyle,
    this.liveDirection = LiveValueDirection.flat,
    this.liveUpdateId,
    super.key,
  });

  final double ltp;
  final double change;
  final double changePercent;
  final bool showDirection;
  final CrossAxisAlignment alignment;
  final TextStyle? priceStyle;
  final TextStyle? changeStyle;
  final LiveValueDirection liveDirection;
  final int? liveUpdateId;

  @override
  Widget build(BuildContext context) {
    final resolvedPriceStyle =
        priceStyle ??
        context.appTextStyles.priceSmall.copyWith(
          color: context.appColors.textPrimary,
        );
    final normalPriceColor =
        resolvedPriceStyle.color ??
        DefaultTextStyle.of(context).style.color ??
        context.appColors.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        LiveValueFlash(
          direction: liveDirection,
          updateId: liveUpdateId,
          normalColor: normalPriceColor,
          builder: (color) => SensitiveValueText(
            FinancialFormatter.price(ltp),
            type: SensitiveValueType.currency,
            isMasked: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: resolvedPriceStyle.copyWith(color: color),
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
