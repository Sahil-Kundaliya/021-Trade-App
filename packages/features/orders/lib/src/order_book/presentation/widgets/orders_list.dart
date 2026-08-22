import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import 'order_details_bottom_sheet.dart';
import 'order_tile.dart';
import 'orders_empty_state.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({required this.orders, super.key});

  final List<TradeOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const OrdersEmptyState();

    final groups = <DateTime, List<TradeOrder>>{};
    for (final order in orders) {
      final date = DateTime(
        order.orderTime.year,
        order.orderTime.month,
        order.orderTime.day,
      );
      groups.putIfAbsent(date, () => []).add(order);
    }
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var dateIndex = 0; dateIndex < dates.length; dateIndex++) ...[
          if (dateIndex > 0) const SizedBox(height: AppSpacing.xxl),
          Text(
            dateIndex == 0
                ? 'TODAY'
                : dateIndex == 1
                ? 'YESTERDAY'
                : _date(dates[dateIndex]),
            style: context.appTextStyles.tableHeader.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (
            var index = 0;
            index < groups[dates[dateIndex]]!.length;
            index++
          ) ...[
            OrderTile(
              order: groups[dates[dateIndex]]![index],
              onTap: () => OrderDetailsBottomSheet.show(
                context,
                groups[dates[dateIndex]]![index],
              ),
            ),
            if (index < groups[dates[dateIndex]]!.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

String _date(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
