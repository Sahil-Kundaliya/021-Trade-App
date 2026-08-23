import 'package:auto_route/auto_route.dart';
import 'package:dashboard/dashboard.dart';
import 'package:orders/orders.dart';
import 'package:orderbook/orderbook.dart';
import 'package:portfolio/portfolio.dart';
import 'package:profile/profile.dart';
import 'package:watchlist/watchlist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigation_scope.dart';
import 'package:zero_two_one_trade_assignment/app/theme/theme_bloc.dart';

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
class ProfileRoutePage extends StatefulWidget {
  const ProfileRoutePage({super.key});

  @override
  State<ProfileRoutePage> createState() => _ProfileRoutePageState();
}

class _ProfileRoutePageState extends State<ProfileRoutePage> {
  late final ProfileBloc _profileBloc = getIt<ProfileBloc>()
    ..add(const ProfileStarted());

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>();
    return ProfilePage(
      bloc: _profileBloc,
      navigator: AppNavigationScope.of(context),
      themeMode: themeBloc.state.mode,
      onThemeChanged: (mode) => themeBloc.add(ThemeModeChanged(mode)),
    );
  }
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

@RoutePage(name: 'LicenceRoute')
class LicenceRoutePage extends StatelessWidget {
  const LicenceRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const LicenceScreen();
}
