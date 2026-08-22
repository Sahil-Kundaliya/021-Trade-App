import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/watchlist_stock.dart';

class WatchlistStockTile extends StatelessWidget {
  const WatchlistStockTile({required this.stock, super.key});

  final WatchlistStock stock;

  @override
  Widget build(BuildContext context) {
    final movementColor = stock.changePercent >= 0
        ? context.appColors.positive
        : context.appColors.negative;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  stock.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xxs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    for (final tag in stock.tags) _StockTag(label: tag),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatRupees(stock.ltp),
                style: context.appTextStyles.priceSmall.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${_formatSigned(stock.change)}  '
                '${_formatSigned(stock.changePercent)}%',
                style: context.appTextStyles.percentageSmall.copyWith(
                  color: movementColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockTag extends StatelessWidget {
  const _StockTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: AppRadius.xsBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.appColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

String _formatRupees(double value) => '\u20B9${_formatNumber(value)}';

String _formatSigned(double value) {
  final sign = value >= 0 ? '+' : '-';
  return '$sign${_formatNumber(value.abs())}';
}

String _formatNumber(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts.first;

  if (whole.length <= 3) return '$whole.${parts.last}';

  final lastThree = whole.substring(whole.length - 3);
  final leading = whole.substring(0, whole.length - 3);
  final groupedLeading = leading.replaceAllMapped(
    RegExp(r'\B(?=(\d{2})+(?!\d))'),
    (_) => ',',
  );
  return '$groupedLeading,$lastThree.${parts.last}';
}
