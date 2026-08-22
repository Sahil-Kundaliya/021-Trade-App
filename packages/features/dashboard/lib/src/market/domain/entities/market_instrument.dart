import 'market_category.dart';

class MarketInstrument {
  const MarketInstrument({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.category,
    required this.exchange,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.tags,
    required this.expiryDate,
    required this.strikePrice,
    required this.optionType,
    required this.underlyingSymbol,
  });

  final String id;
  final String symbol;
  final String companyName;
  final MarketCategory category;
  final String exchange;
  final double ltp;
  final double change;
  final double changePercent;
  final int volume;
  final List<String> tags;
  final DateTime? expiryDate;
  final double? strikePrice;
  final String? optionType;
  final String? underlyingSymbol;
}
