final class AppPreferencesException implements Exception {
  const AppPreferencesException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppPreferencesException: $message';
}
