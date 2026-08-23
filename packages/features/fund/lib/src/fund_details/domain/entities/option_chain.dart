import 'package:core_data/core_data.dart';

enum OptionSide { call, put }

enum OptionMoneyness { itm, atm, otm }

class OptionContract {
  const OptionContract({
    required this.fundId,
    required this.exchange,
    required this.marketKey,
    required this.symbol,
    required this.underlyingSymbol,
    required this.expiry,
    required this.strikeMinor,
    required this.side,
    required this.ltpMinor,
    required this.previousCloseMinor,
    required this.tickSizeMinor,
    required this.lotSize,
    this.openInterest,
    this.impliedVolatility,
  });

  final String fundId;
  final TradeExchange exchange;
  final String marketKey;
  final String symbol;
  final String underlyingSymbol;
  final DateTime expiry;
  final int strikeMinor;
  final OptionSide side;
  final int ltpMinor;
  final int previousCloseMinor;
  final int tickSizeMinor;
  final int lotSize;
  final int? openInterest;
  final double? impliedVolatility;

  double get strike => strikeMinor / 100;
  double get ltp => ltpMinor / 100;
  double get previousClose => previousCloseMinor / 100;
  double get changePercent => previousCloseMinor == 0
      ? 0
      : (ltpMinor - previousCloseMinor) / previousCloseMinor * 100;

  OptionContract withLtpMinor(int value) => OptionContract(
    fundId: fundId,
    exchange: exchange,
    marketKey: marketKey,
    symbol: symbol,
    underlyingSymbol: underlyingSymbol,
    expiry: expiry,
    strikeMinor: strikeMinor,
    side: side,
    ltpMinor: value,
    previousCloseMinor: previousCloseMinor,
    tickSizeMinor: tickSizeMinor,
    lotSize: lotSize,
    openInterest: openInterest,
    impliedVolatility: impliedVolatility,
  );
}

class OptionContractViewData {
  const OptionContractViewData({
    required this.fundId,
    required this.marketKey,
    required this.symbol,
    required this.side,
    required this.ltpMinor,
    required this.changePercent,
    this.openInterest,
  });

  final String fundId;
  final String marketKey;
  final String symbol;
  final OptionSide side;
  final int ltpMinor;
  final double changePercent;
  final int? openInterest;

  double get ltp => ltpMinor / 100;
}

class OptionChainRow {
  const OptionChainRow({
    required this.strikeMinor,
    this.call,
    this.put,
    this.isAtm = false,
    this.isSelectedStrike = false,
  });

  final int strikeMinor;
  final OptionContractViewData? call;
  final OptionContractViewData? put;
  final bool isAtm;
  final bool isSelectedStrike;

  double get strike => strikeMinor / 100;

  OptionChainRow copyWith({
    OptionContractViewData? call,
    OptionContractViewData? put,
    bool? isAtm,
    bool? isSelectedStrike,
    bool clearCall = false,
    bool clearPut = false,
  }) => OptionChainRow(
    strikeMinor: strikeMinor,
    call: clearCall ? null : call ?? this.call,
    put: clearPut ? null : put ?? this.put,
    isAtm: isAtm ?? this.isAtm,
    isSelectedStrike: isSelectedStrike ?? this.isSelectedStrike,
  );
}

class FutureOverview {
  const FutureOverview({
    required this.fundId,
    required this.symbol,
    required this.marketKey,
    required this.expiry,
    required this.lotSize,
    required this.ltpMinor,
    required this.previousCloseMinor,
    this.openInterest,
  });

  final String fundId;
  final String symbol;
  final String marketKey;
  final DateTime expiry;
  final int lotSize;
  final int ltpMinor;
  final int previousCloseMinor;
  final int? openInterest;

  double get ltp => ltpMinor / 100;
}

class OptionChainSnapshot {
  const OptionChainSnapshot({
    required this.underlyingSymbol,
    required this.availableExpiries,
    required this.selectedExpiry,
    required this.rows,
    required this.contracts,
    this.nearestFuture,
    this.atmStrikeMinor,
  });

  final String underlyingSymbol;
  final List<DateTime> availableExpiries;
  final DateTime? selectedExpiry;
  final List<OptionChainRow> rows;
  final List<OptionContract> contracts;
  final FutureOverview? nearestFuture;
  final int? atmStrikeMinor;

  bool get hasContracts => rows.isNotEmpty;
}

abstract final class OptionChainAssembler {
  static int? atmStrikeMinor({
    required Iterable<int> strikes,
    required int spotMinor,
  }) {
    final unique = strikes.toSet().toList()..sort();
    if (unique.isEmpty) return null;
    var best = unique.first;
    var bestDistance = (best - spotMinor).abs();
    for (final strike in unique.skip(1)) {
      final distance = (strike - spotMinor).abs();
      if (distance < bestDistance) {
        best = strike;
        bestDistance = distance;
      }
    }
    return best;
  }

  static OptionMoneyness moneyness({
    required OptionSide side,
    required int strikeMinor,
    required int spotMinor,
    required int? atmMinor,
  }) {
    if (atmMinor != null && strikeMinor == atmMinor) {
      return OptionMoneyness.atm;
    }
    if (side == OptionSide.call) {
      return spotMinor > strikeMinor ? OptionMoneyness.itm : OptionMoneyness.otm;
    }
    return spotMinor < strikeMinor ? OptionMoneyness.itm : OptionMoneyness.otm;
  }

  static int intrinsicMinor({
    required OptionSide side,
    required int strikeMinor,
    required int spotMinor,
  }) {
    if (side == OptionSide.call) {
      final value = spotMinor - strikeMinor;
      return value > 0 ? value : 0;
    }
    final value = strikeMinor - spotMinor;
    return value > 0 ? value : 0;
  }

  static int timeValueMinor({
    required int optionLtpMinor,
    required int intrinsicMinor,
  }) {
    final value = optionLtpMinor - intrinsicMinor;
    return value > 0 ? value : 0;
  }

  static int basisMinor({
    required int futureLtpMinor,
    required int spotMinor,
  }) => futureLtpMinor - spotMinor;

  static List<OptionChainRow> rows({
    required Iterable<OptionContract> contracts,
    required DateTime expiry,
    int? spotMinor,
    int? selectedStrikeMinor,
  }) {
    final matching = contracts
        .where((contract) => sameDay(contract.expiry, expiry))
        .toList(growable: false);
    final strikes = matching.map((contract) => contract.strikeMinor).toSet()
      ..toList();
    final ordered = strikes.toList()..sort();
    final atm = spotMinor == null
        ? null
        : atmStrikeMinor(strikes: ordered, spotMinor: spotMinor);
    return [
      for (final strike in ordered)
        OptionChainRow(
          strikeMinor: strike,
          call: _view(
            matching
                .where(
                  (contract) =>
                      contract.strikeMinor == strike &&
                      contract.side == OptionSide.call,
                )
                .firstOrNull,
          ),
          put: _view(
            matching
                .where(
                  (contract) =>
                      contract.strikeMinor == strike &&
                      contract.side == OptionSide.put,
                )
                .firstOrNull,
          ),
          isAtm: atm == strike,
          isSelectedStrike: selectedStrikeMinor == strike,
        ),
    ];
  }

  static OptionContractViewData? _view(OptionContract? contract) {
    if (contract == null) return null;
    return OptionContractViewData(
      fundId: contract.fundId,
      marketKey: contract.marketKey,
      symbol: contract.symbol,
      side: contract.side,
      ltpMinor: contract.ltpMinor,
      changePercent: contract.changePercent,
      openInterest: contract.openInterest,
    );
  }

  static bool sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
