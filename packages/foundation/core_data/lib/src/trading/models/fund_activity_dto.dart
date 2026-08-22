import '../parsing/json_value_reader.dart';

class FundActivityDto {
  const FundActivityDto({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
  factory FundActivityDto.fromJson(Map<String, dynamic> json) =>
      FundActivityDto(
        id: JsonValueReader.string(json, 'id'),
        type: JsonValueReader.string(json, 'type'),
        title: JsonValueReader.string(json, 'title'),
        description: JsonValueReader.string(json, 'description'),
        timestamp: JsonValueReader.date(json, 'timestamp'),
      );
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
}
