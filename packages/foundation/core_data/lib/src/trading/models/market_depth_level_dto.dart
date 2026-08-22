import '../parsing/json_value_reader.dart';

class MarketDepthLevelDto {
  const MarketDepthLevelDto({
    required this.price,
    required this.quantity,
    required this.orderCount,
  });

  factory MarketDepthLevelDto.fromJson(Map<String, dynamic> json) {
    return MarketDepthLevelDto(
      price: JsonValueReader.number(json, 'price'),
      quantity: JsonValueReader.integer(json, 'quantity'),
      orderCount: JsonValueReader.integer(json, 'orderCount'),
    );
  }

  final double price;
  final int quantity;
  final int orderCount;
}
