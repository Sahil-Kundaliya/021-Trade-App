import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_radius.dart';
import '../../theme/tokens/app_spacing.dart';
import '../../theme/tokens/app_sizes.dart';
import 'market_index_view_data.dart';
import '../../privacy/privacy_mode_scope.dart';
import '../../privacy/sensitive_value_text.dart';

class MarketIndexChip extends StatelessWidget {
  const MarketIndexChip({required this.item, this.onTap, super.key});

  static const double width = AppSizes.marketIndexWidth;
  static const double height = AppSizes.marketIndexHeight;

  final MarketIndexViewData item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final movementColor = item.isPositive
        ? context.appColors.positive
        : context.appColors.negative;

    return Semantics(
      button: onTap != null,
      label: PrivacyModeScope.of(context)
          ? '${item.name}, values hidden'
          : '${item.name}, ${item.value}, ${item.change}, ${item.changePercent}',
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
                    item.value,
                    type: SensitiveValueType.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTextStyles.financialSmall.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SensitiveValueText(
                        item.change,
                        type: SensitiveValueType.number,
                        style: context.appTextStyles.percentageSmall.copyWith(
                          color: movementColor,
                        ),
                      ),
                      SensitiveValueText(
                        item.changePercent,
                        type: SensitiveValueType.percentage,
                        style: context.appTextStyles.percentageSmall.copyWith(
                          color: movementColor,
                        ),
                      ),
                    ],
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
