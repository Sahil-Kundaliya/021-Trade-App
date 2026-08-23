import 'package:core_data/core_data.dart';

class WatchlistFund {
  WatchlistFund({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.category,
    required this.ltp,
    required this.change,
    required this.changePercent,
    this.previousClose = 1,
    this.tickSize = 0.05,
    required List<String> tags,
  }) : tags = List<String>.unmodifiable(tags);

  final String id;
  final String symbol;
  final String companyName;
  final String exchange;
  final String category;
  final double ltp;
  final double change;
  final double changePercent;
  final double previousClose;
  final double tickSize;
  final List<String> tags;

  WatchlistFund withLivePrice(LivePriceTick tick) => WatchlistFund(
    id: id,
    symbol: symbol,
    companyName: companyName,
    exchange: exchange,
    category: category,
    ltp: tick.ltp,
    change: tick.change,
    changePercent: tick.changePercent,
    previousClose: previousClose,
    tickSize: tickSize,
    tags: tags,
  );
}
