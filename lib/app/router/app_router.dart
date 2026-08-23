import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/router/route_pages.dart';
import 'package:zero_two_one_trade_assignment/app/shell/main_shell_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainShellRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard', initial: true),
        AutoRoute(page: WatchlistRoute.page, path: 'watchlist'),
        AutoRoute(page: PortfolioRoute.page, path: 'portfolio'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
    AutoRoute(page: OrdersRoute.page, path: '/orders'),
    AutoRoute(page: OrderBookRoute.page, path: '/order-book'),
  ];
}
