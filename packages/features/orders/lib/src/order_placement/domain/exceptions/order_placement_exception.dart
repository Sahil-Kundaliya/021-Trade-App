class OrderInstrumentNotFoundException implements Exception {
  const OrderInstrumentNotFoundException(this.fundId);
  final String fundId;

  @override
  String toString() => 'No instrument found for $fundId.';
}
