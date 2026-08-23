class LivePriceException implements Exception {
  const LivePriceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'LivePriceException: $message';
}
