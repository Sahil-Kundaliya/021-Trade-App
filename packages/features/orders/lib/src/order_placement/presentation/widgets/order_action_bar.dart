import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/order_enums.dart';
import '../bloc/order_placement_bloc.dart';
import '../bloc/order_placement_event.dart';
import '../bloc/order_placement_state.dart';

class OrderActionBar extends StatelessWidget {
  const OrderActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      OrderPlacementBloc,
      OrderPlacementState,
      ({
        OrderPlacementStatus status,
        OrderSide side,
        double estimatedValue,
        bool enabled,
      })
    >(
      selector: (state) => (
        status: state.status,
        side: state.side,
        estimatedValue: state.estimatedOrderValue,
        enabled:
            state.quantity > 0 && state.status == OrderPlacementStatus.ready,
      ),
      builder: (context, data) {
        if (data.status != OrderPlacementStatus.ready) {
          return const SizedBox.shrink();
        }
        final buy = data.side == OrderSide.buy;
        final actionColor = buy
            ? context.appColors.buy
            : context.appColors.sell;
        return Material(
          color: context.appColors.surface,
          child: SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.appColors.divider),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Value',
                            style: context.appTextStyles.caption.copyWith(
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          SensitiveValueText(
                            FinancialFormatter.price(data.estimatedValue),
                            type: SensitiveValueType.currency,
                            style: context.appTextStyles.orderValue.copyWith(
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      height: AppSizes.buttonHeightMd,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: context.appColors.textInverse,
                          minimumSize: const Size(112, AppSizes.buttonHeightMd),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdBorderRadius,
                          ),
                        ),
                        onPressed: data.enabled
                            ? () => context.read<OrderPlacementBloc>().add(
                                const OrderReviewRequested(),
                              )
                            : null,
                        child: Text(buy ? 'BUY' : 'SELL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
