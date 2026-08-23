class LiveInstrumentSeed {
  const LiveInstrumentSeed({
    required this.instrumentId,
    required this.symbol,
    required this.ltpMinor,
    required this.previousCloseMinor,
    required this.tickSizeMinor,
  });

  factory LiveInstrumentSeed.fromPrices({
    required String instrumentId,
    required String symbol,
    required double ltp,
    required double previousClose,
    required double tickSize,
  }) => LiveInstrumentSeed(
    instrumentId: instrumentId,
    symbol: symbol,
    ltpMinor: (ltp * 100).round(),
    previousCloseMinor: (previousClose * 100).round(),
    tickSizeMinor: (tickSize * 100).round().clamp(1, 1 << 31),
  );

  final String instrumentId;
  final String symbol;
  final int ltpMinor;
  final int previousCloseMinor;
  final int tickSizeMinor;

  Map<String, Object> toMessage() => {
    'instrumentId': instrumentId,
    'symbol': symbol,
    'ltpMinor': ltpMinor,
    'previousCloseMinor': previousCloseMinor,
    'tickSizeMinor': tickSizeMinor,
  };
}
