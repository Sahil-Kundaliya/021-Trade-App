import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orderbook/presentation/bloc/orderbook_bloc.dart';
import '../../../orderbook/presentation/bloc/orderbook_event.dart';
import '../../../orderbook/presentation/bloc/orderbook_state.dart';
import '../../../orderbook/presentation/widgets/orderbook_empty_state.dart';
import '../../../orderbook/presentation/widgets/orderbook_list.dart';
import '../../../orderbook/presentation/widgets/orderbook_tabs.dart';
import 'orderbook_skeleton.dart';

class OrderBookContent extends StatelessWidget {
  const OrderBookContent({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Order Book')),
    body: SafeArea(
      child: BlocBuilder<OrderBookBloc, OrderBookState>(
        builder: (context, state) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: OrderBookTabs(
                    selected: state.selectedTab,
                    openCount: state.openCount,
                    closedCount: state.closedCount,
                    onSelected: (tab) => context.read<OrderBookBloc>().add(
                      OrderBookTabChanged(tab),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: context.motionDuration(AppMotion.standard),
                    switchInCurve: AppMotionCurves.enter,
                    switchOutCurve: AppMotionCurves.exit,
                    child: _Body(
                      key: ValueKey((
                        state.status,
                        state.selectedTab,
                        state.visibleOrders
                            .map((order) => '${order.orderId}:${order.status}')
                            .join(','),
                      )),
                      state: state,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.state, super.key});
  final OrderBookState state;

  @override
  Widget build(BuildContext context) => switch (state.status) {
    OrderBookStatus.initial ||
    OrderBookStatus.loading => const OrderBookSkeleton(),
    OrderBookStatus.error => AppErrorState(
      title: 'Unable to load orders.',
      description: 'Please try loading your order book again.',
      onRetry: () =>
          context.read<OrderBookBloc>().add(const OrderBookRetryRequested()),
    ),
    OrderBookStatus.empty => OrderBookEmptyState(tab: state.selectedTab),
    OrderBookStatus.loaded =>
      state.visibleOrders.isEmpty
          ? OrderBookEmptyState(tab: state.selectedTab)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: OrderBookList(orders: state.visibleOrders),
            ),
  };
}
