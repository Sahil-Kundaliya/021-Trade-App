import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/trade_order.dart';
import 'order_details_bottom_sheet.dart';
import 'orderbook_tile.dart';

class OrderBookList extends StatelessWidget {
  const OrderBookList({required this.orders, super.key});
  final List<TradeOrder> orders;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<TradeOrder>>{};
    for (final order in orders) {
      final date = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      groups.putIfAbsent(date, () => <TradeOrder>[]).add(order);
    }
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var dateIndex = 0; dateIndex < dates.length; dateIndex++) ...[
          if (dateIndex > 0) const SizedBox(height: AppSpacing.xxl),
          Text(
            _dateLabel(dates[dateIndex]),
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
            OrderBookTile(
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

String _dateLabel(DateTime value) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(value).inDays;
  if (difference == 0) return 'TODAY';
  if (difference == 1) return 'YESTERDAY';
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
