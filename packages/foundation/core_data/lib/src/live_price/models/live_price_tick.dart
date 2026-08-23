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

    final directionName = value<String>('direction');
    return LivePriceTick(
      instrumentId: value<String>('instrumentId'),
      symbol: value<String>('symbol'),
      ltpMinor: value<int>('ltpMinor'),
      previousLtpMinor: value<int>('previousLtpMinor'),
      previousCloseMinor: value<int>('previousCloseMinor'),
      changeMinor: value<int>('changeMinor'),
      changePercent: value<num>('changePercent').toDouble(),
      direction: LivePriceDirection.values.firstWhere(
        (item) => item.name == directionName,
        orElse: () => throw FormatException(
          'Invalid live-price direction: $directionName.',
        ),
      ),
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
}
