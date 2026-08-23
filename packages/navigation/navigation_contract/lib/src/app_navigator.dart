import 'package:core_data/core_data.dart';

enum TradeSide { buy, sell }

abstract interface class AppNavigator {
  void goToDashboard();

  void goToWatchlist();

  void goToPortfolio();

  void goToProfile();

  Future<void> openOrders({
    required String fundId,
    required TradeExchange exchange,
    TradeSide? side,
  });

  Future<void> openOrderBook();

  Future<void> openLicenceInformation();

  Future<void> openFund({
    required String fundId,
    required TradeExchange exchange,
  });

  Future<void> pop();
}
