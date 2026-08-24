import 'package:account_funds/account_funds.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dashboard/dashboard.dart';
import 'package:orders/orders.dart';
import 'package:orderbook/orderbook.dart';
import 'package:portfolio/portfolio.dart';
import 'package:profile/profile.dart';
import 'package:search/search.dart';
import 'package:watchlist/watchlist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigation_scope.dart';
import 'package:zero_two_one_trade_assignment/app/preferences/app_preferences_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_guard.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_policy.dart';

@RoutePage(name: 'DashboardRoute')
class DashboardRoutePage extends StatelessWidget {
  const DashboardRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final privacyMode = context.select<AppPreferencesBloc, bool>(
      (bloc) => bloc.state.preferences.privacyMode,
    );
    return _internetRequired(
      InternetRequiredFeature.dashboard,
      (key) => PrivacyModeScope(
        key: key,
        enabled: privacyMode,
        child: DashboardPage(navigator: AppNavigationScope.of(context)),
      ),
    );
  }
}

@RoutePage(name: 'WatchlistRoute')
class WatchlistRoutePage extends StatelessWidget {
  const WatchlistRoutePage({super.key});

  @override
  Widget build(BuildContext context) => _internetRequired(
    InternetRequiredFeature.watchlist,
    (key) => WatchlistPage(key: key, navigator: AppNavigationScope.of(context)),
  );
}

@RoutePage(name: 'PortfolioRoute')
class PortfolioRoutePage extends StatelessWidget {
  const PortfolioRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    final privacyMode = context.select<AppPreferencesBloc, bool>(
      (bloc) => bloc.state.preferences.privacyMode,
    );
    return _internetRequired(
      InternetRequiredFeature.portfolio,
      (key) => PrivacyModeScope(
        key: key,
        enabled: privacyMode,
        child: PortfolioPage(navigator: AppNavigationScope.of(context)),
      ),
    );
  }
}

@RoutePage(name: 'ProfileRoute')
class ProfileRoutePage extends StatefulWidget {
  const ProfileRoutePage({super.key});

  @override
  State<ProfileRoutePage> createState() => _ProfileRoutePageState();
}

class _ProfileRoutePageState extends State<ProfileRoutePage> {
  bool _permissionRefreshed = false;
  late final ProfileBloc _profileBloc = getIt<ProfileBloc>()
    ..add(const ProfileStarted());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_permissionRefreshed) return;
    _permissionRefreshed = true;
    context.read<AppPreferencesBloc>().add(
      const AppNotificationPermissionRefreshed(),
    );
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencesBloc = context.watch<AppPreferencesBloc>();
    final appState = preferencesBloc.state;
    return ProfilePage(
      bloc: _profileBloc,
      navigator: AppNavigationScope.of(context),
      themeMode: appState.preferences.themeMode,
      privacyMode: appState.preferences.privacyMode,
      notificationsEnabled: appState.notificationsEffective,
      notificationPermissionBlocked:
          appState.notificationPermission ==
          NotificationPermissionStatus.denied,
      onThemeChanged: (mode) => preferencesBloc.add(AppThemeModeChanged(mode)),
      onPrivacyChanged: (enabled) =>
          preferencesBloc.add(AppPrivacyModeChanged(enabled)),
      onNotificationsChanged: (enabled) =>
          preferencesBloc.add(AppNotificationsChanged(enabled)),
    );
  }
}

@RoutePage(name: 'OrdersRoute')
class OrdersRoutePage extends StatelessWidget {
  const OrdersRoutePage({
    required this.fundId,
    required this.exchange,
    this.side,
    super.key,
  });

  final String fundId;
  final TradeExchange exchange;
  final TradeSide? side;

  @override
  Widget build(BuildContext context) => _internetRequired(
    InternetRequiredFeature.orders,
    (key) => OrdersScreen(
      key: key,
      fundId: fundId,
      exchange: exchange,
      side: side,
      navigator: AppNavigationScope.of(context),
    ),
  );
}

@RoutePage(name: 'AccountFundsRoute')
class AccountFundsRoutePage extends StatelessWidget {
  const AccountFundsRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const AccountFundsScreen();
}

@RoutePage(name: 'OrderBookRoute')
class OrderBookRoutePage extends StatelessWidget {
  const OrderBookRoutePage({super.key});

  @override
  Widget build(BuildContext context) => _internetRequired(
    InternetRequiredFeature.orderBook,
    (key) => OrderBookScreen(key: key),
  );
}

@RoutePage(name: 'LicenceRoute')
class LicenceRoutePage extends StatelessWidget {
  const LicenceRoutePage({super.key});

  @override
  Widget build(BuildContext context) => const LicenceScreen();
}

@RoutePage(name: 'SearchRoute')
class SearchRoutePage extends StatelessWidget {
  const SearchRoutePage({super.key});

  @override
  Widget build(BuildContext context) => _internetRequired(
    InternetRequiredFeature.search,
    (key) => SearchScreen(key: key, navigator: AppNavigationScope.of(context)),
  );
}

Widget _internetRequired(
  InternetRequiredFeature feature,
  ConnectivityChildBuilder builder,
) {
  assert(ConnectivityPolicy.internetRequired.contains(feature));
  return ConnectivityGuard(childBuilder: builder);
}
