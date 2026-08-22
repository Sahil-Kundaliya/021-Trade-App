import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({required this.onFilterPressed, super.key});

  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: 'Orders',
      trailing: AppIconButton(
        key: const Key('orders-filter-button'),
        tooltip: 'Filter orders',
        onPressed: onFilterPressed,
        icon: const Icon(Icons.tune_outlined, size: AppSizes.iconMd),
      ),
    );
  }
}
