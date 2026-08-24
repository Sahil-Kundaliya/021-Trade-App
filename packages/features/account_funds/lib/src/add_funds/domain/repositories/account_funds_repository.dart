import '../entities/account_funds_data.dart';

abstract interface class AccountFundsRepository {
  Future<AccountFundsData> getAccountFunds();

  Future<AccountFundsData> addFunds({
    required double amount,
    required String bankId,
  });
}
