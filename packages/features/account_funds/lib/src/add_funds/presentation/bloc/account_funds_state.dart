import '../../domain/account_funds_money.dart';
import '../../domain/entities/linked_bank_account.dart';

enum AccountFundsStatus { initial, loading, loaded, error }

class AccountFundsState {
  const AccountFundsState({
    this.status = AccountFundsStatus.initial,
    this.availableBalance = 0,
    this.banks = const [],
    this.selectedBankId,
    this.enteredAmount = '',
    this.validationMessage,
    this.isAdding = false,
    this.addError,
    this.successMessage,
    this.loadError,
    this.feedbackEpoch = 0,
  });

  final AccountFundsStatus status;
  final double availableBalance;
  final List<LinkedBankAccount> banks;
  final String? selectedBankId;
  final String enteredAmount;
  final String? validationMessage;
  final bool isAdding;
  final String? addError;
  final String? successMessage;
  final String? loadError;
  final int feedbackEpoch;

  double? get parsedAmount => AccountFundsMoney.tryParse(enteredAmount);

  bool get canSubmit {
    if (status != AccountFundsStatus.loaded || isAdding) return false;
    if (selectedBankId == null) return false;
    final amount = parsedAmount;
    if (amount == null) return false;
    final paise = AccountFundsMoney.toPaise(amount);
    return paise > 0 && paise <= AccountFundsMoney.maxAddPaise;
  }

  AccountFundsState copyWith({
    AccountFundsStatus? status,
    double? availableBalance,
    List<LinkedBankAccount>? banks,
    String? selectedBankId,
    String? enteredAmount,
    String? validationMessage,
    bool? isAdding,
    String? addError,
    String? successMessage,
    String? loadError,
    int? feedbackEpoch,
    bool clearValidation = false,
    bool clearAddError = false,
    bool clearSuccess = false,
    bool clearLoadError = false,
  }) => AccountFundsState(
    status: status ?? this.status,
    availableBalance: availableBalance ?? this.availableBalance,
    banks: banks ?? this.banks,
    selectedBankId: selectedBankId ?? this.selectedBankId,
    enteredAmount: enteredAmount ?? this.enteredAmount,
    validationMessage: clearValidation
        ? null
        : validationMessage ?? this.validationMessage,
    isAdding: isAdding ?? this.isAdding,
    addError: clearAddError ? null : addError ?? this.addError,
    successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    loadError: clearLoadError ? null : loadError ?? this.loadError,
    feedbackEpoch: feedbackEpoch ?? this.feedbackEpoch,
  );
}
