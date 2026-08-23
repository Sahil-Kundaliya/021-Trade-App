import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/holding.dart';
import 'holding_tile.dart';
import 'holdings_empty_state.dart';

class HoldingsList extends StatelessWidget {
  const HoldingsList({required this.holdings, this.onHoldingTap, super.key});

  final List<Holding> holdings;
  final ValueChanged<Holding>? onHoldingTap;

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) return const HoldingsEmptyState();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border.all(color: context.appColors.borderSubtle),
        borderRadius: AppRadius.mdBorderRadius,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.mdBorderRadius,
        child: Column(
          children: [
            for (var index = 0; index < holdings.length; index++) ...[
              HoldingTile(
                key: ValueKey(holdings[index].marketKey),
                holding: holdings[index],
                onTap: onHoldingTap == null
                    ? null
                    : () => onHoldingTap!(holdings[index]),
              ),
              if (index != holdings.length - 1) const AppDivider(),
            ],
          ],
        ),
      ),
    );
  }
}
