import 'package:core_data/core_data.dart';

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
    required this.previousClose,
    required this.tickSize,
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
  final double previousClose;
  final double tickSize;
  final int volume;
  final List<String> tags;
  final DateTime? expiryDate;
  final double? strikePrice;
  final String? optionType;
  final String? underlyingSymbol;

  MarketInstrument withLivePrice(LivePriceTick tick) => MarketInstrument(
    id: id,
    symbol: symbol,
    companyName: companyName,
    category: category,
    exchange: exchange,
    ltp: tick.ltp,
    change: tick.change,
    changePercent: tick.changePercent,
    previousClose: previousClose,
    tickSize: tickSize,
    volume: volume,
    tags: tags,
    expiryDate: expiryDate,
    strikePrice: strikePrice,
    optionType: optionType,
    underlyingSymbol: underlyingSymbol,
  );
}
