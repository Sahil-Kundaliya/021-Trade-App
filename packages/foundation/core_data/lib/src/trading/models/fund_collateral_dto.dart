import '../exceptions/trading_data_exception.dart';
import '../parsing/json_value_reader.dart';

class FundCollateralDto {
  const FundCollateralDto({
    required this.isEligible,
    required this.haircutPercent,
    required this.eligibleValue,
    required this.postHaircutValue,
  });

  factory FundCollateralDto.fromJson(Map<String, dynamic> json) {
    final eligible = json['isEligible'];
    if (eligible is! bool) {
      throw const TradingDataException('Expected a boolean at "isEligible".');
    }
    return FundCollateralDto(
      isEligible: eligible,
      haircutPercent: JsonValueReader.number(json, 'haircutPercent'),
      eligibleValue: JsonValueReader.number(json, 'eligibleValue'),
      postHaircutValue: JsonValueReader.number(json, 'postHaircutValue'),
    );
  }

  final bool isEligible;
  final double haircutPercent;
  final double eligibleValue;
  final double postHaircutValue;
}
