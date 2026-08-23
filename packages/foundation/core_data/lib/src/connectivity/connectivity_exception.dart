final class ConnectivityException implements Exception {
  const ConnectivityException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'ConnectivityException: $message';
}
