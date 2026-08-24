import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/account_funds_data.dart';
import '../../domain/repositories/account_funds_repository.dart';
import '../mappers/account_funds_mapper.dart';

@LazySingleton(as: AccountFundsRepository)
final class AccountFundsRepositoryImpl implements AccountFundsRepository {
  AccountFundsRepositoryImpl(this._api);

  static const _uuid = Uuid();
  final AccountFundsLocalApi _api;
  var _adding = false;

  @override
  Future<AccountFundsData> getAccountFunds() async {
    final storage = await _api.read();
    return AccountFundsMapper.toDomain(
      storage: storage,
      banks: _api.linkedBanks,
    );
  }

  @override
  Future<AccountFundsData> addFunds({
    required double amount,
    required String bankId,
  }) async {
    if (_adding) {
      throw const AccountFundsException('Add funds is already in progress.');
    }
    _adding = true;
    try {
      final storage = await _api.addFunds(
        depositId: 'deposit_${_uuid.v4()}',
        amount: amount,
        bankId: bankId,
      );
      return AccountFundsMapper.toDomain(
        storage: storage,
        banks: _api.linkedBanks,
      );
    } finally {
      _adding = false;
    }
  }
}
