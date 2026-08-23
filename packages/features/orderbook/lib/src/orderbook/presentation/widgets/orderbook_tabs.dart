import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../bloc/orderbook_event.dart';

class OrderBookTabs extends StatelessWidget {
  const OrderBookTabs({
    required this.selected,
    required this.openCount,
    required this.closedCount,
    required this.onSelected,
    super.key,
  });

  final OrderBookTab selected;
  final int openCount;
  final int closedCount;
  final ValueChanged<OrderBookTab> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: context.appColors.borderSubtle)),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Tab(
            label: 'Open ($openCount)',
            selected: selected == OrderBookTab.open,
            onTap: () => onSelected(OrderBookTab.open),
          ),
        ),
        Expanded(
          child: _Tab(
            label: 'Closed ($closedCount)',
            selected: selected == OrderBookTab.closed,
            onTap: () => onSelected(OrderBookTab.closed),
          ),
        ),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Semantics(
      selected: selected,
      button: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? context.appColors.primary
                  : context.appColors.borderSubtle.withValues(alpha: 0),
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.labelLarge?.copyWith(
            color: selected
                ? context.appColors.primary
                : context.appColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
