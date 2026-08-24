final class AccountFundsException implements Exception {
  const AccountFundsException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
