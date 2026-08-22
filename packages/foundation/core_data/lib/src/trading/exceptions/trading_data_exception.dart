class TradingDataException implements Exception {
  const TradingDataException(this.message);

  final String message;

  @override
  String toString() => 'TradingDataException: $message';
}
