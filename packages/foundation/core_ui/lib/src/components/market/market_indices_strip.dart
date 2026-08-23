import 'package:flutter/material.dart';

import '../../theme/tokens/app_spacing.dart';
import 'market_index_chip.dart';
import 'market_index_view_data.dart';

class MarketIndicesStrip extends StatelessWidget {
  const MarketIndicesStrip({required this.items, this.onItemTap, super.key})
    : itemCount = null,
      itemBuilder = null;

  const MarketIndicesStrip.builder({
    required int this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    super.key,
  }) : items = null,
       onItemTap = null;

  final List<MarketIndexViewData>? items;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final ValueChanged<MarketIndexViewData>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final count = itemCount ?? items!.length;
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      height: MarketIndexChip.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final builder = itemBuilder;
          if (builder != null) return builder(context, index);
          final item = items![index];
          return MarketIndexChip(
            item: item,
            onTap: onItemTap == null ? null : () => onItemTap!(item),
          );
        },
      ),
    );
  }
}
