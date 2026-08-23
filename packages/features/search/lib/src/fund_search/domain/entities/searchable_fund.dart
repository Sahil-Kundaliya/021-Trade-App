import 'package:core_data/core_data.dart';

enum SearchCategory {
  all('All'),
  equity('Equity'),
  future('Futures'),
  options('Options');

  const SearchCategory(this.label);

  final String label;
}

class SearchableFund {
  const SearchableFund({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.category,
    required this.instrumentType,
    required this.exchange,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required this.previousClose,
    required this.tickSize,
    required this.tags,
  });

  final String id;
  final String symbol;
  final String companyName;
  final SearchCategory category;
  final String instrumentType;
  final TradeExchange exchange;
  final double ltp;
  final double change;
  final double changePercent;
  final double previousClose;
  final double tickSize;
  final List<String> tags;

  String get marketKey =>
      MarketInstrumentKey(fundId: id, exchange: exchange).value;

  SearchableFund withLivePrice(LivePriceTick tick) => SearchableFund(
    id: id,
    symbol: symbol,
    companyName: companyName,
    category: category,
    instrumentType: instrumentType,
    exchange: exchange,
    ltp: tick.ltp,
    change: tick.change,
    changePercent: tick.changePercent,
    previousClose: previousClose,
    tickSize: tickSize,
    tags: tags,
  );
}
