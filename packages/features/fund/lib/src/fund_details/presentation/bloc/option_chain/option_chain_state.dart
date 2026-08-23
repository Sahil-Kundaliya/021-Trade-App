import 'package:core_data/core_data.dart';

import '../../../domain/entities/option_chain.dart';

enum OptionChainStatus { idle, loading, loaded, error }

sealed class OptionChainEvent {
  const OptionChainEvent();
}

final class OptionChainStarted extends OptionChainEvent {
  const OptionChainStarted({
    required this.underlyingSymbol,
    required this.exchange,
    this.selectedStrikeMinor,
  });

  final String underlyingSymbol;
  final TradeExchange exchange;
  final int? selectedStrikeMinor;
}

final class OptionChainExpiryChanged extends OptionChainEvent {
  const OptionChainExpiryChanged(this.expiry);
  final DateTime expiry;
}

final class OptionChainLivePricesReceived extends OptionChainEvent {
  const OptionChainLivePricesReceived(this.batch);
  final LivePriceBatch batch;
}

final class OptionChainRetryRequested extends OptionChainEvent {
  const OptionChainRetryRequested();
}

final class OptionChainStreamFailed extends OptionChainEvent {
  const OptionChainStreamFailed();
}

class OptionChainState {
  const OptionChainState({
    this.status = OptionChainStatus.idle,
    this.underlyingSymbol = '',
    this.exchange = TradeExchange.nse,
    this.selectedStrikeMinor,
    this.availableExpiries = const [],
    this.selectedExpiry,
    this.rows = const [],
    this.contracts = const [],
    this.underlyingLtpMinor,
    this.atmStrikeMinor,
    this.nearestFuture,
    this.liveUnavailable = false,
    this.errorMessage,
  });

  final OptionChainStatus status;
  final String underlyingSymbol;
  final TradeExchange exchange;
  final int? selectedStrikeMinor;
  final List<DateTime> availableExpiries;
  final DateTime? selectedExpiry;
  final List<OptionChainRow> rows;
  final List<OptionContract> contracts;
  final int? underlyingLtpMinor;
  final int? atmStrikeMinor;
  final FutureOverview? nearestFuture;
  final bool liveUnavailable;
  final String? errorMessage;

  bool get hasContracts => rows.isNotEmpty;
  double? get underlyingLtp =>
      underlyingLtpMinor == null ? null : underlyingLtpMinor! / 100;

  OptionChainState copyWith({
    OptionChainStatus? status,
    String? underlyingSymbol,
    TradeExchange? exchange,
    int? selectedStrikeMinor,
    List<DateTime>? availableExpiries,
    DateTime? selectedExpiry,
    List<OptionChainRow>? rows,
    List<OptionContract>? contracts,
    int? underlyingLtpMinor,
    int? atmStrikeMinor,
    FutureOverview? nearestFuture,
    bool? liveUnavailable,
    String? errorMessage,
    bool clearError = false,
  }) => OptionChainState(
    status: status ?? this.status,
    underlyingSymbol: underlyingSymbol ?? this.underlyingSymbol,
    exchange: exchange ?? this.exchange,
    selectedStrikeMinor: selectedStrikeMinor ?? this.selectedStrikeMinor,
    availableExpiries: availableExpiries ?? this.availableExpiries,
    selectedExpiry: selectedExpiry ?? this.selectedExpiry,
    rows: rows ?? this.rows,
    contracts: contracts ?? this.contracts,
    underlyingLtpMinor: underlyingLtpMinor ?? this.underlyingLtpMinor,
    atmStrikeMinor: atmStrikeMinor ?? this.atmStrikeMinor,
    nearestFuture: nearestFuture ?? this.nearestFuture,
    liveUnavailable: liveUnavailable ?? this.liveUnavailable,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
