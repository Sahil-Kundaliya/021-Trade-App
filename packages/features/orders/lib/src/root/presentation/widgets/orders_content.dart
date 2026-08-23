import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../order_placement/presentation/bloc/order_placement_bloc.dart';
import '../../../order_placement/presentation/bloc/order_placement_event.dart';
import '../../../order_placement/presentation/bloc/order_placement_state.dart';
import '../../../order_placement/domain/enums/order_enums.dart';
import '../../../order_placement/presentation/widgets/order_confirmation.dart';
import '../../../order_placement/presentation/widgets/order_instrument_header.dart';
import '../../../order_placement/presentation/widgets/order_review.dart';
import '../../../order_placement/presentation/widgets/order_ticket.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({required this.navigator, super.key});
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrderPlacementBloc, OrderPlacementState>(
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              _OrdersHeader(state: state, onBack: navigator.pop),
              const AppDivider(),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Builder(
                    builder: (context) {
                      if (state.status == OrderPlacementStatus.loading ||
                          state.status == OrderPlacementStatus.initial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.status == OrderPlacementStatus.success) {
                        return OrderConfirmation(
                          order: state.placedOrder!,
                          onViewOrderBook: navigator.openOrderBook,
                          onDone: navigator.pop,
                        );
                      }
                      if (state.instrument == null) {
                        return AppEmptyState(
                          icon: Icons.error_outline,
                          title: 'Unable to load instrument',
                          description:
                              state.errorMessage ??
                              'Please close this page and try again.',
                          action: AppButton(
                            label: 'Done',
                            onPressed: navigator.pop,
                          ),
                        );
                      }
                      if (state.status == OrderPlacementStatus.review ||
                          state.status == OrderPlacementStatus.placing ||
                          state.status == OrderPlacementStatus.error) {
                        return OrderReview(
                          state: state,
                          onCancel: () => context
                              .read<OrderPlacementBloc>()
                              .add(const OrderReviewCancelled()),
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
          bottomNavigationBar: state.status == OrderPlacementStatus.ready
              ? _ReviewOrderBar(state: state)
              : null,
        ),
      );
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.state, required this.onBack});
  final OrderPlacementState state;
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
          Expanded(
            child: state.instrument == null
                ? Text('Order', style: context.textTheme.titleLarge)
                : OrderInstrumentHeader(instrument: state.instrument!),
          ),
        ],
      ),
    ),
  );
}

class _ReviewOrderBar extends StatelessWidget {
  const _ReviewOrderBar({required this.state});
  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) {
    final buy = state.side == OrderSide.buy;
    final actionColor = buy ? context.appColors.buy : context.appColors.sell;
    return Material(
      color: context.appColors.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.appColors.divider)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: SizedBox(
              height: AppSizes.buttonHeightLg,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: context.appColors.textInverse,
                ),
                onPressed: () => context.read<OrderPlacementBloc>().add(
                  const OrderReviewRequested(),
                ),
                child: Text('Review ${buy ? 'Buy' : 'Sell'} Order'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
