import 'package:flutter/material.dart';

import '../../theme/tokens/app_spacing.dart';
import 'market_index_chip.dart';
import 'market_index_view_data.dart';

class MarketIndicesStrip extends StatelessWidget {
  const MarketIndicesStrip({required this.items, this.onItemTap, super.key});

  final List<MarketIndexViewData> items;
  final ValueChanged<MarketIndexViewData>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: MarketIndexChip.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return MarketIndexChip(
            item: item,
            onTap: onItemTap == null ? null : () => onItemTap!(item),
          );
        },
      ),
    );
  }
}
