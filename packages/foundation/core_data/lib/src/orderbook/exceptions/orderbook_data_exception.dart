final class OrderBookDataException implements Exception {
  const OrderBookDataException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
