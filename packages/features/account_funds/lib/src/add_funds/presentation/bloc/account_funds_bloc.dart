import 'package:core_ui/core_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/account_funds_money.dart';
import '../../domain/repositories/account_funds_repository.dart';
import 'account_funds_event.dart';
import 'account_funds_state.dart';

@injectable
class AccountFundsBloc extends Bloc<AccountFundsEvent, AccountFundsState> {
  AccountFundsBloc(this._repository) : super(const AccountFundsState()) {
    on<AccountFundsStarted>(_load);
    on<AccountFundsRetryRequested>(_load);
    on<AccountFundsAmountChanged>(_amountChanged);
    on<AccountFundsQuickAmountSelected>(_quickAmountSelected);
    on<AccountFundsBankSelected>(_bankSelected);
    on<AccountFundsAddRequested>(_addRequested);
  }

  final AccountFundsRepository _repository;

  Future<void> _load(
    AccountFundsEvent event,
    Emitter<AccountFundsState> emit,
  ) async {
    if (state.status == AccountFundsStatus.loading || state.isAdding) return;
    emit(
      state.copyWith(
        status: AccountFundsStatus.loading,
        clearLoadError: true,
        clearAddError: true,
        clearSuccess: true,
      ),
    );
    try {
      final data = await _repository.getAccountFunds();
      emit(
        state.copyWith(
          status: AccountFundsStatus.loaded,
          availableBalance: data.balance.available,
          banks: data.banks,
          selectedBankId: data.primaryBank?.id,
          clearLoadError: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: AccountFundsStatus.error,
          loadError: AccountFundsMoney.loadFailureMessage,
        ),
      );
    }
  }

  void _amountChanged(
    AccountFundsAmountChanged event,
    Emitter<AccountFundsState> emit,
  ) {
    if (state.status != AccountFundsStatus.loaded || state.isAdding) return;
    emit(
      state.copyWith(
        enteredAmount: event.value,
        validationMessage: AccountFundsMoney.validationMessage(event.value),
        clearValidation:
            AccountFundsMoney.validationMessage(event.value) == null,
        clearAddError: true,
        clearSuccess: true,
      ),
    );
  }

  void _quickAmountSelected(
    AccountFundsQuickAmountSelected event,
    Emitter<AccountFundsState> emit,
  ) {
    if (state.status != AccountFundsStatus.loaded || state.isAdding) return;
    final text = FinancialFormatter.decimals(event.amount);
    emit(
      state.copyWith(
        enteredAmount: text,
        validationMessage: AccountFundsMoney.validationMessage(text),
        clearValidation: AccountFundsMoney.validationMessage(text) == null,
        clearAddError: true,
        clearSuccess: true,
      ),
    );
  }

  void _bankSelected(
    AccountFundsBankSelected event,
    Emitter<AccountFundsState> emit,
  ) {
    if (state.status != AccountFundsStatus.loaded || state.isAdding) return;
    if (!state.banks.any((bank) => bank.id == event.bankId)) return;
    emit(
      state.copyWith(
        selectedBankId: event.bankId,
        clearAddError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> _addRequested(
    AccountFundsAddRequested event,
    Emitter<AccountFundsState> emit,
  ) async {
    if (state.isAdding || state.status != AccountFundsStatus.loaded) return;
    final amount = state.parsedAmount;
    final bankId = state.selectedBankId;
    final validation = AccountFundsMoney.validationMessage(state.enteredAmount);
    if (amount == null || bankId == null || validation != null) {
      emit(
        state.copyWith(
          validationMessage:
              validation ?? AccountFundsMoney.greaterThanZeroMessage,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isAdding: true,
        clearAddError: true,
        clearSuccess: true,
        clearValidation: true,
      ),
    );
    try {
      final data = await _repository.addFunds(amount: amount, bankId: bankId);
      emit(
        state.copyWith(
          isAdding: false,
          availableBalance: data.balance.available,
          banks: data.banks,
          enteredAmount: '',
          successMessage: AccountFundsMoney.addSuccessMessage,
          addedAmount: amount,
          feedbackEpoch: state.feedbackEpoch + 1,
          clearValidation: true,
          clearAddError: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isAdding: false,
          addError: AccountFundsMoney.addFailureMessage,
          feedbackEpoch: state.feedbackEpoch + 1,
        ),
      );
    }
  }
}
