import 'package:core_data/core_data.dart';

enum FundHistoryPeriod { oneMonth, threeMonths }

sealed class FundDetailsEvent {
  const FundDetailsEvent();
}

final class FundDetailsStarted extends FundDetailsEvent {
  const FundDetailsStarted({
    required this.fundId,
    this.exchange = TradeExchange.nse,
  });
  final String fundId;
  final TradeExchange exchange;
}

final class FundDetailsRetryRequested extends FundDetailsEvent {
  const FundDetailsRetryRequested();
}

final class FundHistoryPeriodChanged extends FundDetailsEvent {
  const FundHistoryPeriodChanged(this.period);
  final FundHistoryPeriod period;
}

final class FundAddToWatchlistOpened extends FundDetailsEvent {
  const FundAddToWatchlistOpened();
}

final class FundAddToWatchlistDismissed extends FundDetailsEvent {
  const FundAddToWatchlistDismissed();
}

final class FundWatchlistSelected extends FundDetailsEvent {
  const FundWatchlistSelected({required this.watchlistId});
  final String watchlistId;
}

final class FundAddToWatchlistRequested extends FundDetailsEvent {
  const FundAddToWatchlistRequested();
}

final class FundRemoveFromWatchlistRequested extends FundDetailsEvent {
  const FundRemoveFromWatchlistRequested();
}

final class FundLivePricesReceived extends FundDetailsEvent {
  const FundLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}

final class FundOrdersChanged extends FundDetailsEvent {
  const FundOrdersChanged(this.orders);
  final List<OrderDto> orders;
}

final class FundWatchlistsChanged extends FundDetailsEvent {
  const FundWatchlistsChanged();
}
