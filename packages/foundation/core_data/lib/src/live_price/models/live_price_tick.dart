enum LivePriceDirection { up, down, flat }

class LivePriceTick {
  const LivePriceTick({
    required this.instrumentId,
    required this.symbol,
    required this.ltpMinor,
    required this.previousLtpMinor,
    required this.previousCloseMinor,
    required this.changeMinor,
    required this.changePercent,
    required this.direction,
    required this.timestamp,
    required this.sequence,
  });

  factory LivePriceTick.fromMessage(
    Map<Object?, Object?> message, {
    required int batchSequence,
    required DateTime batchTimestamp,
  }) {
    T value<T>(String key) {
      final raw = message[key];
      if (raw is T) return raw;
      throw FormatException('Invalid live-price field: $key.');
    }

    final ltpMinor = value<int>('ltpMinor');
    final previousLtpMinor = value<int>('previousLtpMinor');
    final previousCloseMinor = value<int>('previousCloseMinor');
    if (ltpMinor <= 0 || previousCloseMinor <= 0) {
      throw const FormatException('Live prices must be positive.');
    }
    final changeMinor = ltpMinor - previousCloseMinor;
    return LivePriceTick(
      instrumentId: value<String>('instrumentId'),
      symbol: value<String>('symbol'),
      ltpMinor: ltpMinor,
      previousLtpMinor: previousLtpMinor,
      previousCloseMinor: previousCloseMinor,
      changeMinor: changeMinor,
      changePercent: changeMinor / previousCloseMinor * 100,
      direction: ltpMinor > previousLtpMinor
          ? LivePriceDirection.up
          : ltpMinor < previousLtpMinor
          ? LivePriceDirection.down
          : LivePriceDirection.flat,
      timestamp: batchTimestamp,
      sequence: batchSequence,
    );
  }

  final String instrumentId;
  final String symbol;
  final int ltpMinor;
  final int previousLtpMinor;
  final int previousCloseMinor;
  final int changeMinor;
  final double changePercent;
  final LivePriceDirection direction;
  final DateTime timestamp;
  final int sequence;

  double get ltp => ltpMinor / 100;
  double get previousLtp => previousLtpMinor / 100;
  double get previousClose => previousCloseMinor / 100;
  double get change => changeMinor / 100;

  LivePriceTick withInstrumentId(String value) => LivePriceTick(
    instrumentId: value,
    symbol: symbol,
    ltpMinor: ltpMinor,
    previousLtpMinor: previousLtpMinor,
    previousCloseMinor: previousCloseMinor,
    changeMinor: changeMinor,
    changePercent: changePercent,
    direction: direction,
    timestamp: timestamp,
    sequence: sequence,
  );
}
