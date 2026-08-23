import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/searchable_fund.dart';

class SearchFundTile extends StatelessWidget {
  const SearchFundTile({required this.fund, this.onTap, super.key});

  final SearchableFund fund;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final movementColor = fund.changePercent >= 0
        ? context.appColors.positive
        : context.appColors.negative;
    return Semantics(
      button: onTap != null,
      label: '${fund.symbol}, ${fund.exchange.code}, ${fund.category.label}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      fund.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${fund.exchange.code} • ${fund.category.label}',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SensitiveValueText(
                    '₹${fund.ltp.toStringAsFixed(2)}',
                    type: SensitiveValueType.currency,
                    style: context.appTextStyles.priceSmall.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SensitiveValueText(
                    '${fund.changePercent >= 0 ? '+' : ''}'
                    '${fund.changePercent.toStringAsFixed(2)}%',
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
    );
  }
}
