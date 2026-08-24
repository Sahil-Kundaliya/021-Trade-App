abstract interface class ProfileFundsRepository {
  Future<double> getAvailableBalance();
  Stream<double> watchAvailableBalance();
}
