import '../parsing/json_value_reader.dart';

class HoldingDto {
  const HoldingDto({
    required this.id,
    required this.fundId,
    required this.symbol,
    required this.companyName,
    required this.underlyingSymbol,
    required this.category,
    required this.instrumentType,
    required this.exchange,
    required this.quantity,
    required this.lots,
    required this.lotSize,
    required this.averageCost,
    required this.ltp,
    required this.investedValue,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
    required this.marginBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HoldingDto.fromJson(
    Map<String, dynamic> json, {
    String? companyName,
  }) {
    final underlyingSymbol = JsonValueReader.string(json, 'underlyingSymbol');
    return HoldingDto(
      id: JsonValueReader.string(json, 'id'),
      fundId: JsonValueReader.string(json, 'fundId'),
      symbol: JsonValueReader.string(json, 'symbol'),
      companyName: companyName ?? underlyingSymbol,
      underlyingSymbol: underlyingSymbol,
      category: JsonValueReader.string(json, 'category'),
      instrumentType: JsonValueReader.string(json, 'instrumentType'),
      exchange: JsonValueReader.string(json, 'exchange'),
      quantity: JsonValueReader.integer(json, 'quantity'),
      lots: JsonValueReader.nullableInteger(json, 'lots'),
      lotSize: JsonValueReader.integer(json, 'lotSize'),
      averageCost: JsonValueReader.number(json, 'averageCost'),
      ltp: JsonValueReader.number(json, 'ltp'),
      investedValue: JsonValueReader.number(json, 'investedValue'),
      currentValue: JsonValueReader.number(json, 'currentValue'),
      pnl: JsonValueReader.number(json, 'pnl'),
      pnlPercent: JsonValueReader.number(json, 'pnlPercent'),
      marginBlocked: JsonValueReader.number(json, 'marginBlocked'),
      createdAt: JsonValueReader.date(json, 'createdAt'),
      updatedAt: JsonValueReader.date(json, 'updatedAt'),
    );
  }

  final String id;
  final String fundId;
  final String symbol;
  final String companyName;
  final String underlyingSymbol;
  final String category;
  final String instrumentType;
  final String exchange;
  final int quantity;
  final int? lots;
  final int lotSize;
  final double averageCost;
  final double ltp;
  final double investedValue;
  final double currentValue;
  final double pnl;
  final double pnlPercent;
  final double marginBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;
}
