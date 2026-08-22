import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../order_book/data/mock_orders_data.dart';
import '../../../order_book/presentation/widgets/order_status_tabs.dart';
import '../../../order_book/presentation/widgets/orders_filter_bar.dart';
import '../../../order_book/presentation/widgets/orders_header.dart';
import '../../../order_book/presentation/widgets/orders_list.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderStatusTab _selectedTab = OrderStatusTab.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrdersHeader(
                    onFilterPressed: () => OrdersFilterBar.show(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OrderStatusTabs(
                    selected: _selectedTab,
                    onSelected: (tab) => setState(() => _selectedTab = tab),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  OrdersList(orders: mockOrders),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
