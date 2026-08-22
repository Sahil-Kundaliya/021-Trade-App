import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

enum OrderStatusTab { all, open, executed, cancelled }

class OrderStatusTabs extends StatelessWidget {
  const OrderStatusTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final OrderStatusTab selected;
  final ValueChanged<OrderStatusTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in OrderStatusTab.values) ...[
            AppChip(
              key: Key('orders-tab-${tab.name}'),
              label: _label(tab),
              selected: selected == tab,
              onSelected: (_) => onSelected(tab),
            ),
            if (tab != OrderStatusTab.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

String _label(OrderStatusTab tab) => switch (tab) {
  OrderStatusTab.all => 'All',
  OrderStatusTab.open => 'Open',
  OrderStatusTab.executed => 'Executed',
  OrderStatusTab.cancelled => 'Cancelled',
};
