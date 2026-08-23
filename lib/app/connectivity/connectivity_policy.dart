/// The application-wide offline policy.
///
/// Main trading flows are Internet-required. Profile preferences and Licence
/// remain local-capable so users can still change device settings and read
/// regulatory information while offline.
abstract final class ConnectivityPolicy {
  static const Set<InternetRequiredFeature> internetRequired = {
    InternetRequiredFeature.dashboard,
    InternetRequiredFeature.watchlist,
    InternetRequiredFeature.portfolio,
    InternetRequiredFeature.fund,
    InternetRequiredFeature.orders,
    InternetRequiredFeature.orderBook,
    InternetRequiredFeature.search,
  };
}

enum InternetRequiredFeature {
  dashboard,
  watchlist,
  portfolio,
  fund,
  orders,
  orderBook,
  search,
}
