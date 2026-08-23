import 'package:core_data/core_data.dart';

sealed class WatchlistEvent {
  const WatchlistEvent();
}

final class WatchlistStarted extends WatchlistEvent {
  const WatchlistStarted();
}

final class WatchlistRetryRequested extends WatchlistEvent {
  const WatchlistRetryRequested();
}

final class WatchlistDataChanged extends WatchlistEvent {
  const WatchlistDataChanged();
}

final class WatchlistSelected extends WatchlistEvent {
  const WatchlistSelected({required this.watchlistId});
  final String watchlistId;
}

final class WatchlistCreateRequested extends WatchlistEvent {
  const WatchlistCreateRequested({required this.name});
  final String name;
}

final class WatchlistRenameRequested extends WatchlistEvent {
  const WatchlistRenameRequested({
    required this.watchlistId,
    required this.newName,
  });
  final String watchlistId;
  final String newName;
}

final class WatchlistDeleteRequested extends WatchlistEvent {
  const WatchlistDeleteRequested({required this.watchlistId});
  final String watchlistId;
}

final class WatchlistFundAddRequested extends WatchlistEvent {
  const WatchlistFundAddRequested({
    required this.watchlistId,
    required this.fundId,
  });
  final String watchlistId;
  final String fundId;
}

final class WatchlistFundRemoveRequested extends WatchlistEvent {
  const WatchlistFundRemoveRequested({
    required this.watchlistId,
    required this.fundId,
  });
  final String watchlistId;
  final String fundId;
}

final class WatchlistFundsReorderRequested extends WatchlistEvent {
  const WatchlistFundsReorderRequested({
    required this.watchlistId,
    required this.oldIndex,
    required this.newIndex,
  });
  final String watchlistId;
  final int oldIndex;
  final int newIndex;
}

final class WatchlistLivePricesReceived extends WatchlistEvent {
  const WatchlistLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}
