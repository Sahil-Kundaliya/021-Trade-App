import 'package:flutter/material.dart';

import '../../formatters/financial_formatter.dart';
import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_radius.dart';
import '../../theme/tokens/app_spacing.dart';
import '../../theme/tokens/app_sizes.dart';
import 'market_index_view_data.dart';
import '../../privacy/sensitive_value_text.dart';
import 'market_price_change.dart';
import 'market_price_display_scope.dart';

class MarketIndexChip extends StatelessWidget {
  const MarketIndexChip({required this.item, this.onTap, super.key});

  static const double width = AppSizes.marketIndexWidth;
  static const double height = AppSizes.marketIndexHeight;

  final MarketIndexViewData item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = FinancialFormatter.price(item.ltp, symbol: false);
    final changeLabel = switch (MarketPriceDisplayScope.of(context)) {
      MarketPriceDisplayMode.absoluteAndPercent =>
        FinancialFormatter.changeGroup(item.change, item.changePercent),
      MarketPriceDisplayMode.percentOnly => FinancialFormatter.percentage(
        item.changePercent,
      ),
      MarketPriceDisplayMode.absoluteOnly => FinancialFormatter.change(
        item.change,
      ),
    };

    return Semantics(
      button: onTap != null,
      label: '${item.name}, $price, $changeLabel',
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: context.appColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius,
            side: BorderSide(color: context.appColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTextStyles.label.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SensitiveValueText(
                    price,
                    type: SensitiveValueType.number,
                    isMasked: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTextStyles.financialSmall.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MarketPriceChange(
                      change: item.change,
                      changePercent: item.changePercent,
                      isMasked: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
