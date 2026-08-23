import 'package:auto_route/auto_route.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:fund/fund.dart';
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
  Future<void> openOrders({required String fundId, TradeSide? side}) =>
      _router.push<void>(OrdersRoute(fundId: fundId, side: side));

  @override
  Future<void> openOrderBook() => _router.push<void>(const OrderBookRoute());

  @override
  Future<void> openLicenceInformation() =>
      _router.push<void>(const LicenceRoute());

  @override
  Future<void> openFund({required String fundId}) async {
    final context = _router.navigatorKey.currentContext;
    if (context == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: context.appColors.surface.withValues(alpha: 0),
      builder: (_) => FundSheet(fundId: fundId, navigator: this),
    );
  }

  @override
  Future<void> pop() async {
    final context = _router.navigatorKey.currentContext;
    if (context != null) {
      await Navigator.of(context).maybePop();
    }
  }

  void _openTab(PageRouteInfo route) {
    _router.navigate(MainShellRoute(children: [route]));
  }
}
