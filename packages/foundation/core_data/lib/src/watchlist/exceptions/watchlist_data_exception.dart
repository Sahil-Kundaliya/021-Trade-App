class WatchlistDataException implements Exception {
  const WatchlistDataException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'WatchlistDataException: $message';
}
