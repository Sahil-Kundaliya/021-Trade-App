import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../order_placement/presentation/bloc/order_placement_bloc.dart';
import '../../../order_placement/presentation/bloc/order_placement_event.dart';
import '../../../order_placement/presentation/bloc/order_placement_state.dart';
import '../../../order_placement/presentation/widgets/order_action_bar.dart';
import '../../../order_placement/presentation/widgets/order_confirmation.dart';
import '../../../order_placement/presentation/widgets/order_instrument_header.dart';
import '../../../order_placement/presentation/widgets/order_review.dart';
import '../../../order_placement/presentation/widgets/order_ticket.dart';
import 'order_placement_skeleton.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({required this.navigator, super.key});
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        _OrdersHeader(onBack: navigator.pop),
        const AppDivider(),
        Expanded(
          child: SafeArea(
            top: false,
            child: BlocBuilder<OrderPlacementBloc, OrderPlacementState>(
              buildWhen: _bodyShouldRebuild,
              builder: (context, state) {
                if (state.status == OrderPlacementStatus.loading ||
                    state.status == OrderPlacementStatus.initial) {
                  return const OrderPlacementSkeleton();
                }
                if (state.status == OrderPlacementStatus.success) {
                  return OrderConfirmation(
                    order: state.placedOrder!,
                    onViewOrderBook: navigator.openOrderBook,
                    onDone: navigator.pop,
                  );
                }
                if (state.instrument == null) {
                  return AppErrorState(
                    title: 'Unable to load instrument',
                    description:
                        state.errorMessage ??
                        'Please close this page and try again.',
                    actionLabel: 'Done',
                    onRetry: navigator.pop,
                  );
                }
                if (state.status == OrderPlacementStatus.review ||
                    state.status == OrderPlacementStatus.placing ||
                    state.status == OrderPlacementStatus.error) {
                  return OrderReview(
                    state: state,
                    onCancel: () => context.read<OrderPlacementBloc>().add(
                      const OrderReviewCancelled(),
                    ),
                    onConfirm: state.isPlacingOrder
                        ? null
                        : () => context.read<OrderPlacementBloc>().add(
                            state.status == OrderPlacementStatus.error
                                ? const OrderPlacementRetryRequested()
                                : const OrderPlacementConfirmed(),
                          ),
                  );
                }
                return OrderTicket(state: state);
              },
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const OrderActionBar(),
  );
}

bool _bodyShouldRebuild(
  OrderPlacementState previous,
  OrderPlacementState current,
) {
  if (previous.status != current.status) return true;
  if (previous.side != current.side) return true;
  if (previous.quantity != current.quantity) return true;
  if (previous.orderType != current.orderType) return true;
  if (previous.product != current.product) return true;
  if (previous.exchange != current.exchange) return true;
  if (previous.limitPrice != current.limitPrice) return true;
  if (previous.triggerPrice != current.triggerPrice) return true;
  if (previous.validity != current.validity) return true;
  if (previous.availableSellQuantity != current.availableSellQuantity) {
    return true;
  }
  if (previous.fieldErrors != current.fieldErrors) return true;
  if (previous.errorMessage != current.errorMessage) return true;
  if (previous.placedOrder?.id != current.placedOrder?.id) return true;
  if (previous.instrument?.id != current.instrument?.id) return true;
  if (previous.instrument?.exchange != current.instrument?.exchange) {
    return true;
  }
  return false;
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          const SizedBox(width: AppSpacing.xs),
          const Expanded(child: OrderInstrumentHeader()),
        ],
      ),
    ),
  );
}
