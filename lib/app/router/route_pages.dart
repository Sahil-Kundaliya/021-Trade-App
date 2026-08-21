import 'package:auto_route/auto_route.dart';
import 'package:dashboard/dashboard.dart';
import 'package:fund/fund.dart';
import 'package:orders/orders.dart';
import 'package:portfolio/portfolio.dart';
import 'package:profile/profile.dart';
import 'package:watchlist/watchlist.dart';
import 'package:flutter/widgets.dart';

@RoutePage(name: 'DashboardRoute')
class DashboardRoutePage extends StatelessWidget {
  const DashboardRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const DashboardPage();
}

@RoutePage(name: 'WatchlistRoute')
class WatchlistRoutePage extends StatelessWidget {
  const WatchlistRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const WatchlistPage();
}

@RoutePage(name: 'PortfolioRoute')
class PortfolioRoutePage extends StatelessWidget {
  const PortfolioRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const PortfolioPage();
}

@RoutePage(name: 'ProfileRoute')
class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const ProfilePage();
}

@RoutePage(name: 'OrdersRoute')
class OrdersRoutePage extends StatelessWidget {
  const OrdersRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const OrdersPage();
}

@RoutePage(name: 'FundRoute')
class FundRoutePage extends StatelessWidget {
  const FundRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const FundPage();
}
