import '../parsing/json_value_reader.dart';
import 'market_depth_level_dto.dart';

class MarketDepthDto {
  const MarketDepthDto({
    required this.bids,
    required this.asks,
    required this.totalBidQuantity,
    required this.totalAskQuantity,
    required this.updatedAt,
  });

  factory MarketDepthDto.fromJson(Map<String, dynamic> json) {
    List<MarketDepthLevelDto> levels(String key) =>
        JsonValueReader.list(json, key)
            .asMap()
            .entries
            .map(
              (entry) => MarketDepthLevelDto.fromJson(
                JsonValueReader.listObject(entry.value, '$key[${entry.key}]'),
              ),
            )
            .toList(growable: false);

    return MarketDepthDto(
      bids: levels('bids'),
      asks: levels('asks'),
      totalBidQuantity: JsonValueReader.integer(json, 'totalBidQuantity'),
      totalAskQuantity: JsonValueReader.integer(json, 'totalAskQuantity'),
      updatedAt: JsonValueReader.date(json, 'updatedAt'),
    );
  }

  final List<MarketDepthLevelDto> bids;
  final List<MarketDepthLevelDto> asks;
  final int totalBidQuantity;
  final int totalAskQuantity;
  final DateTime updatedAt;
}
