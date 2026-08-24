/// The application-wide offline policy.
///
/// Main trading flows are Internet-required. Profile preferences, Licence,
/// and Account Funds remain local-capable so users can still change device
/// settings, read regulatory information, and add demo trading cash while
/// offline.
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
