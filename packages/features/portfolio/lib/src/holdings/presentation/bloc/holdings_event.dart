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
