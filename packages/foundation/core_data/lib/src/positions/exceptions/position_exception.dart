class PositionDataException implements Exception {
  const PositionDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InsufficientPositionException implements Exception {
  const InsufficientPositionException({
    required this.availableQuantity,
    required this.requestedQuantity,
  });

  final int availableQuantity;
  final int requestedQuantity;

  String get message => availableQuantity <= 0
      ? 'No quantity available to sell.'
      : 'Only $availableQuantity quantity available to sell.';

  @override
  String toString() => message;
}
