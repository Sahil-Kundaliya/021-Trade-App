enum TradeSide { buy, sell }

abstract interface class AppNavigator {
  void goToDashboard();

  void goToWatchlist();

  void goToPortfolio();

  void goToProfile();

  Future<void> openOrders({required String fundId, TradeSide? side});

  Future<void> openOrderBook();

  Future<void> openLicenceInformation();

  Future<void> openFund({required String fundId});

  Future<void> pop();
}
