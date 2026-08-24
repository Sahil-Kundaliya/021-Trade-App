import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/account_funds_bloc.dart';
import '../bloc/account_funds_event.dart';
import '../bloc/account_funds_state.dart';

class AddFundsBottomBar extends StatelessWidget {
  const AddFundsBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      AccountFundsBloc,
      AccountFundsState,
      ({bool visible, bool enabled, bool isAdding, double? amount})
    >(
      selector: (state) => (
        visible: state.status == AccountFundsStatus.loaded,
        enabled: state.canSubmit,
        isAdding: state.isAdding,
        amount: state.parsedAmount,
      ),
      builder: (context, data) {
        if (!data.visible) return const SizedBox.shrink();
        final label = data.amount == null || data.amount! <= 0
            ? 'ADD FUNDS'
            : 'ADD ${FinancialFormatter.price(data.amount)}';
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
                child: SizedBox(
                  height: AppSizes.buttonHeightMd,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: data.enabled
                        ? () => context.read<AccountFundsBloc>().add(
                            const AccountFundsAddRequested(),
                          )
                        : null,
                    child: data.isAdding
                        ? SizedBox.square(
                            dimension: AppSizes.iconSm,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.appColors.textInverse,
                            ),
                          )
                        : Text(label),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
