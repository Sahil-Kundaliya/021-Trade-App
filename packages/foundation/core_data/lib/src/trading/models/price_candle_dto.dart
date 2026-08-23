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

  static List<PriceCandleDto> listFrom(
    Map<String, dynamic> json,
    String key,
  ) => JsonValueReader.optionalList(json, key)
      .asMap()
      .entries
      .map(
        (entry) => PriceCandleDto.fromJson(
          JsonValueReader.listObject(entry.value, '$key[${entry.key}]'),
        ),
      )
      .toList(growable: false);

  final DateTime startedAt;
  final double open;
  final double high;
  final double low;
  final double close;
}
