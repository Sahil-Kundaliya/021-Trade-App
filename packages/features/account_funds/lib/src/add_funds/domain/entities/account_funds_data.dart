import 'fund_deposit.dart';
import 'linked_bank_account.dart';
import 'trading_cash_balance.dart';

class AccountFundsData {
  const AccountFundsData({
    required this.balance,
    required this.banks,
    required this.deposits,
  });

  final TradingCashBalance balance;
  final List<LinkedBankAccount> banks;
  final List<FundDeposit> deposits;

  LinkedBankAccount? get primaryBank {
    for (final bank in banks) {
      if (bank.isPrimary) return bank;
    }
    return banks.isEmpty ? null : banks.first;
  }
}
