import '../parsing/json_value_reader.dart';

class PriceHistoryPointDto {
  const PriceHistoryPointDto({required this.date, required this.value});

  factory PriceHistoryPointDto.fromJson(Map<String, dynamic> json) {
    return PriceHistoryPointDto(
      date: JsonValueReader.date(json, 'date'),
      value: JsonValueReader.number(json, 'value'),
    );
  }

  final DateTime date;
  final double value;
}
