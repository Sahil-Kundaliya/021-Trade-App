sealed class AccountFundsEvent {
  const AccountFundsEvent();
}

final class AccountFundsStarted extends AccountFundsEvent {
  const AccountFundsStarted();
}

final class AccountFundsAmountChanged extends AccountFundsEvent {
  const AccountFundsAmountChanged(this.value);

  final String value;
}

final class AccountFundsQuickAmountSelected extends AccountFundsEvent {
  const AccountFundsQuickAmountSelected(this.amount);

  final double amount;
}

final class AccountFundsBankSelected extends AccountFundsEvent {
  const AccountFundsBankSelected(this.bankId);

  final String bankId;
}

final class AccountFundsAddRequested extends AccountFundsEvent {
  const AccountFundsAddRequested();
}

final class AccountFundsRetryRequested extends AccountFundsEvent {
  const AccountFundsRetryRequested();
}
