import 'package:auto_route/auto_route.dart';
import 'package:dashboard/dashboard.dart';
import 'package:orders/orders.dart';
import 'package:orderbook/orderbook.dart';
import 'package:portfolio/portfolio.dart';
import 'package:profile/profile.dart';
import 'package:watchlist/watchlist.dart';
import 'package:flutter/widgets.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigation_scope.dart';

@RoutePage(name: 'DashboardRoute')
class DashboardRoutePage extends StatelessWidget {
  const DashboardRoutePage({super.key});

  @override
  Widget build(BuildContext context) =>
      DashboardPage(navigator: AppNavigationScope.of(context));
}

@RoutePage(name: 'WatchlistRoute')
class WatchlistRoutePage extends StatelessWidget {
  const WatchlistRoutePage({super.key});

  @override
  Widget build(BuildContext context) =>
      WatchlistPage(navigator: AppNavigationScope.of(context));
}

@RoutePage(name: 'PortfolioRoute')
class PortfolioRoutePage extends StatelessWidget {
  const PortfolioRoutePage({super.key});

  @override
  Widget build(BuildContext context) =>
      PortfolioPage(navigator: AppNavigationScope.of(context));
}

@RoutePage(name: 'ProfileRoute')
class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) =>
      ProfilePage(navigator: AppNavigationScope.of(context));
}

@RoutePage(name: 'OrdersRoute')
class OrdersRoutePage extends StatelessWidget {
  const OrdersRoutePage({required this.fundId, this.side, super.key});

  final String fundId;
  final TradeSide? side;

  @override
  Widget build(BuildContext context) => OrdersScreen(
    fundId: fundId,
    side: side,
    navigator: AppNavigationScope.of(context),
  );
}

@RoutePage(name: 'OrderBookRoute')
class OrderBookRoutePage extends StatelessWidget {
  const OrderBookRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const OrderBookScreen();
}
