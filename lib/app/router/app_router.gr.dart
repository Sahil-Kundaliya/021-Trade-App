// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DashboardRoutePage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardRoutePage();
    },
  );
}

/// generated route for
/// [LicenceRoutePage]
class LicenceRoute extends PageRouteInfo<void> {
  const LicenceRoute({List<PageRouteInfo>? children})
    : super(LicenceRoute.name, initialChildren: children);

  static const String name = 'LicenceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LicenceRoutePage();
    },
  );
}

/// generated route for
/// [MainShellPage]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellPage();
    },
  );
}

/// generated route for
/// [OrderBookRoutePage]
class OrderBookRoute extends PageRouteInfo<void> {
  const OrderBookRoute({List<PageRouteInfo>? children})
    : super(OrderBookRoute.name, initialChildren: children);

  static const String name = 'OrderBookRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrderBookRoutePage();
    },
  );
}

/// generated route for
/// [OrdersRoutePage]
class OrdersRoute extends PageRouteInfo<OrdersRouteArgs> {
  OrdersRoute({
    required String fundId,
    TradeSide? side,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         OrdersRoute.name,
         args: OrdersRouteArgs(fundId: fundId, side: side, key: key),
         initialChildren: children,
       );

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrdersRouteArgs>();
      return OrdersRoutePage(
        fundId: args.fundId,
        side: args.side,
        key: args.key,
      );
    },
  );
}

class OrdersRouteArgs {
  const OrdersRouteArgs({required this.fundId, this.side, this.key});

  final String fundId;

  final TradeSide? side;

  final Key? key;

  @override
  String toString() {
    return 'OrdersRouteArgs{fundId: $fundId, side: $side, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrdersRouteArgs) return false;
    return fundId == other.fundId && side == other.side && key == other.key;
  }

  @override
  int get hashCode => fundId.hashCode ^ side.hashCode ^ key.hashCode;
}

/// generated route for
/// [PortfolioRoutePage]
class PortfolioRoute extends PageRouteInfo<void> {
  const PortfolioRoute({List<PageRouteInfo>? children})
    : super(PortfolioRoute.name, initialChildren: children);

  static const String name = 'PortfolioRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PortfolioRoutePage();
    },
  );
}

/// generated route for
/// [ProfileRoutePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileRoutePage();
    },
  );
}

/// generated route for
/// [WatchlistRoutePage]
class WatchlistRoute extends PageRouteInfo<void> {
  const WatchlistRoute({List<PageRouteInfo>? children})
    : super(WatchlistRoute.name, initialChildren: children);

  static const String name = 'WatchlistRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WatchlistRoutePage();
    },
  );
}
