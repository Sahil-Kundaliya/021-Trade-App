abstract interface class AppNavigator {
  void goToDashboard();

  void goToWatchlist();

  void goToPortfolio();

  void goToProfile();

  Future<void> openOrders();

  Future<void> openFund();

  Future<void> pop();
}
