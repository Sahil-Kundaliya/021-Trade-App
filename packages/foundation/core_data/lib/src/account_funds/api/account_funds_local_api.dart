import '../models/account_funds_storage_dto.dart';
import '../models/linked_bank_account_dto.dart';

abstract interface class AccountFundsLocalApi {
  List<LinkedBankAccountDto> get linkedBanks;

  Future<AccountFundsStorageDto> read();

  Future<AccountFundsStorageDto> addFunds({
    required String depositId,
    required double amount,
    required String bankId,
  });
}
