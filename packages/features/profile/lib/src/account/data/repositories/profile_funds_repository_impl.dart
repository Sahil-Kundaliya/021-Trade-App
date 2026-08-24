import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/profile_funds_repository.dart';

@LazySingleton(as: ProfileFundsRepository)
final class ProfileFundsRepositoryImpl implements ProfileFundsRepository {
  const ProfileFundsRepositoryImpl(this._accountFundsLocalApi);

  final AccountFundsLocalApi _accountFundsLocalApi;

  @override
  Future<double> getAvailableBalance() async {
    final funds = await _accountFundsLocalApi.read();
    return funds.availableBalance;
  }

  @override
  Stream<double> watchAvailableBalance() =>
      _accountFundsLocalApi.balanceChanges;
}
