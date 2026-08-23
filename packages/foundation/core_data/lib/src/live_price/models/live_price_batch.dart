import 'live_price_tick.dart';

class LivePriceBatch {
  const LivePriceBatch({
    required this.sequence,
    required this.timestamp,
    required this.updates,
  });

  factory LivePriceBatch.fromMessage(Object? raw) {
    if (raw is! Map<Object?, Object?>) {
      throw const FormatException('Live-price batch must be a map.');
    }
    final sequence = raw['sequence'];
    final timestamp = raw['timestamp'];
    final updates = raw['updates'];
    if (sequence is! int || timestamp is! int || updates is! List<Object?>) {
      throw const FormatException('Invalid live-price batch.');
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return LivePriceBatch(
      sequence: sequence,
      timestamp: date,
      updates: List<LivePriceTick>.unmodifiable(
        updates.map((item) {
          if (item is! Map<Object?, Object?>) {
            throw const FormatException('Invalid live-price update.');
          }
          return LivePriceTick.fromMessage(
            item,
            batchSequence: sequence,
            batchTimestamp: date,
          );
        }),
      ),
    );
  }

  final int sequence;
  final DateTime timestamp;
  final List<LivePriceTick> updates;
}
