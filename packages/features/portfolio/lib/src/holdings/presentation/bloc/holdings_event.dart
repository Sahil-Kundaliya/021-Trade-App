import 'package:core_data/core_data.dart';

import 'holdings_sort.dart';

sealed class HoldingsEvent {
  const HoldingsEvent();
}

final class HoldingsStarted extends HoldingsEvent {
  const HoldingsStarted();
}

final class HoldingsSortChanged extends HoldingsEvent {
  const HoldingsSortChanged(this.sort);

  final HoldingsSort sort;
}

final class HoldingsRetryRequested extends HoldingsEvent {
  const HoldingsRetryRequested();
}

final class HoldingsLivePricesReceived extends HoldingsEvent {
  const HoldingsLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}
