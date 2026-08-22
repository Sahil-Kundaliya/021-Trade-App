import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No orders yet',
      description: 'Your placed orders will appear here.',
      icon: Icons.receipt_long_outlined,
    );
  }
}
