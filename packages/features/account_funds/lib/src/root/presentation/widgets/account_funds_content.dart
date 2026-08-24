import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../add_funds/presentation/bloc/account_funds_bloc.dart';
import '../../../add_funds/presentation/bloc/account_funds_event.dart';
import '../../../add_funds/presentation/bloc/account_funds_state.dart';
import '../../../add_funds/presentation/widgets/add_bank_account_tile.dart';
import '../../../add_funds/presentation/widgets/add_bank_demo_sheet.dart';
import '../../../add_funds/presentation/widgets/add_funds_amount_field.dart';
import '../../../add_funds/presentation/widgets/add_funds_bottom_bar.dart';
import '../../../add_funds/presentation/widgets/add_funds_confirmation.dart';
import '../../../add_funds/presentation/widgets/available_funds_summary.dart';
import '../../../add_funds/presentation/widgets/linked_bank_list.dart';
import '../../../add_funds/presentation/widgets/quick_amount_selector.dart';
import 'account_funds_skeleton.dart';

class AccountFundsContent extends StatelessWidget {
  const AccountFundsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountFundsBloc, AccountFundsState>(
      listenWhen: (previous, current) =>
          previous.feedbackEpoch != current.feedbackEpoch &&
          current.addError != null,
      listener: (context, state) {
        final message = state.addError;
        if (message == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Add Funds'),
          leading: BackButton(onPressed: () => _returnToSource(context)),
        ),
        resizeToAvoidBottomInset: true,
        body: state.successMessage != null && state.addedAmount != null
            ? SafeArea(
                child: AddFundsConfirmation(
                  addedAmount: state.addedAmount!,
                  availableBalance: state.availableBalance,
                  onDone: () => _returnToSource(context),
                ),
              )
            : SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: _Body(state: state),
                  ),
                ),
              ),
        bottomNavigationBar:
            state.successMessage != null && state.addedAmount != null
            ? null
            : const AddFundsBottomBar(),
      ),
    );
  }
}

void _returnToSource(BuildContext context) {
  Navigator.of(context).maybePop();
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final AccountFundsState state;

  @override
  Widget build(BuildContext context) => switch (state.status) {
    AccountFundsStatus.initial ||
    AccountFundsStatus.loading => const AccountFundsSkeleton(),
    AccountFundsStatus.error => AppErrorState(
      title: 'Unable to load account funds.',
      description: 'Please try loading your trading cash balance again.',
      onRetry: () => context.read<AccountFundsBloc>().add(
        const AccountFundsRetryRequested(),
      ),
    ),
    AccountFundsStatus.loaded => _LoadedForm(state: state),
  };
}

class _LoadedForm extends StatelessWidget {
  const _LoadedForm({required this.state});

  final AccountFundsState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AccountFundsBloc>();
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AvailableFundsSummary(balance: state.availableBalance),
          const SizedBox(height: AppSpacing.xxl),
          AddFundsAmountField(
            amountInput: state.enteredAmount,
            validationMessage: state.validationMessage,
            enabled: !state.isAdding,
            onChanged: (value) => bloc.add(AccountFundsAmountChanged(value)),
          ),
          const SizedBox(height: AppSpacing.lg),
          QuickAmountSelector(
            selectedAmount: state.parsedAmount,
            enabled: !state.isAdding,
            onSelected: (amount) =>
                bloc.add(AccountFundsQuickAmountSelected(amount)),
          ),
          const SizedBox(height: AppSpacing.xxl),
          LinkedBankList(
            banks: state.banks,
            selectedBankId: state.selectedBankId,
            onSelected: (bankId) => bloc.add(AccountFundsBankSelected(bankId)),
          ),
          const SizedBox(height: AppSpacing.sm),
          AddBankAccountTile(onTap: () => showAddBankDemoSheet(context)),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Demo trading balance',
            style: context.appTextStyles.caption.copyWith(
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Funds added here are stored locally on this device and do not represent real money.',
            style: context.appTextStyles.caption.copyWith(
              color: context.appColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
