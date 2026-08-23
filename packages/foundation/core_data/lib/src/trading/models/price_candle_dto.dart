import '../parsing/json_value_reader.dart';

class PriceCandleDto {
  const PriceCandleDto({
    required this.startedAt,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory PriceCandleDto.fromJson(Map<String, dynamic> json) => PriceCandleDto(
    startedAt: JsonValueReader.date(json, 'startedAt'),
    open: JsonValueReader.number(json, 'open'),
    high: JsonValueReader.number(json, 'high'),
    low: JsonValueReader.number(json, 'low'),
    close: JsonValueReader.number(json, 'close'),
  );

  final DateTime startedAt;
  final double open;
  final double high;
  final double low;
  final double close;
}
