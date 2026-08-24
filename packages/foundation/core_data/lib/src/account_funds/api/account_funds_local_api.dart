import '../models/account_funds_storage_dto.dart';
import '../models/linked_bank_account_dto.dart';

abstract interface class AccountFundsLocalApi {
  List<LinkedBankAccountDto> get linkedBanks;
  Stream<double> get balanceChanges;

  Future<AccountFundsStorageDto> read();

  Future<AccountFundsStorageDto> addFunds({
    required String depositId,
    required double amount,
    required String bankId,
  });

  Future<AccountFundsStorageDto> debitFunds({required double amount});
}
