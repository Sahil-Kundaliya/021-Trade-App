import 'package:auto_route/auto_route.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/router/app_router.dart';

final class AppNavigatorImpl implements AppNavigator {
  AppNavigatorImpl(this._router);

  final StackRouter _router;

  @override
  void goToDashboard() => _openTab(const DashboardRoute());

  @override
  void goToWatchlist() => _openTab(const WatchlistRoute());

  @override
  void goToPortfolio() => _openTab(const PortfolioRoute());

  @override
  void goToProfile() => _openTab(const ProfileRoute());

  @override
  Future<void> openOrders() => _router.push<void>(const OrdersRoute());

  @override
  Future<void> openFund() => _router.push<void>(const FundRoute());

  @override
  Future<void> pop() async {
    await _router.maybePop();
  }

  void _openTab(PageRouteInfo route) {
    _router.navigate(MainShellRoute(children: [route]));
  }
}
