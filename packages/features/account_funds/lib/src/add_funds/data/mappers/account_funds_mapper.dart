import 'package:core_data/core_data.dart';

import '../../domain/entities/account_funds_data.dart';
import '../../domain/entities/fund_deposit.dart';
import '../../domain/entities/linked_bank_account.dart';
import '../../domain/entities/trading_cash_balance.dart';

abstract final class AccountFundsMapper {
  static AccountFundsData toDomain({
    required AccountFundsStorageDto storage,
    required List<LinkedBankAccountDto> banks,
  }) => AccountFundsData(
    balance: TradingCashBalance(available: storage.availableBalance),
    banks: List<LinkedBankAccount>.unmodifiable(banks.map(toBank)),
    deposits: List<FundDeposit>.unmodifiable(storage.deposits.map(toDeposit)),
  );

  static LinkedBankAccount toBank(LinkedBankAccountDto dto) =>
      LinkedBankAccount(
        id: dto.id,
        bankName: dto.bankName,
        last4: dto.last4,
        accountType: dto.accountType.toLowerCase() == 'current'
            ? BankAccountType.current
            : BankAccountType.savings,
        isPrimary: dto.isPrimary,
      );

  static FundDeposit toDeposit(LocalFundDepositDto dto) => FundDeposit(
    id: dto.id,
    amount: dto.amount,
    bankId: dto.bankId,
    createdAt: dto.createdAt,
  );
}
