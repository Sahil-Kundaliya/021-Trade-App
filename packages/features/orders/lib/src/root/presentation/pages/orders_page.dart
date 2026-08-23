import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: SafeArea(
        child: const AppEmptyState(
          icon: Icons.swap_vert_circle_outlined,
          title: 'Order entry',
          description: 'Buy and sell order placement will be available here.',
        ),
      ),
    );
  }
}
