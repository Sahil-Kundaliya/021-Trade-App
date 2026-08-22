import '../parsing/json_value_reader.dart';

class FundMarginDto {
  const FundMarginDto({
    this.delivery,
    this.intraday,
    this.overnight,
    this.span,
    this.exposure,
  });

  factory FundMarginDto.fromJson(Map<String, dynamic> json) => FundMarginDto(
    delivery: JsonValueReader.nullableNumber(json, 'delivery'),
    intraday: JsonValueReader.nullableNumber(json, 'intraday'),
    overnight: JsonValueReader.nullableNumber(json, 'overnight'),
    span: JsonValueReader.nullableNumber(json, 'span'),
    exposure: JsonValueReader.nullableNumber(json, 'exposure'),
  );

  final double? delivery;
  final double? intraday;
  final double? overnight;
  final double? span;
  final double? exposure;
}
