import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../bloc/orderbook_event.dart';

class OrderBookEmptyState extends StatelessWidget {
  const OrderBookEmptyState({required this.tab, super.key});

  final OrderBookTab tab;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: Icons.receipt_long_outlined,
    title: tab == OrderBookTab.open ? 'No open orders' : 'No closed orders',
    description: tab == OrderBookTab.open
        ? 'Active orders will appear here.'
        : 'Completed, cancelled, and rejected orders will appear here.',
  );
}
