import 'package:core_data/core_data.dart';

class Holding {
  const Holding({
    required this.id,
    required this.fundId,
    required this.symbol,
    required this.companyName,
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
    required this.previousClose,
    required this.tickSize,
  });

  final String id;
  final String fundId;
  final String symbol;
  final String companyName;
  final String category;
  final String instrumentType;
  final String exchange;
  TradeExchange get tradeExchange => TradeExchange.parse(exchange);
  String get marketKey =>
      MarketInstrumentKey(fundId: fundId, exchange: tradeExchange).value;
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
  final double previousClose;
  final double tickSize;

  Holding withLivePrice(LivePriceTick tick) {
    final nextCurrentValue = quantity * tick.ltp;
    final nextPnl = nextCurrentValue - investedValue;
    return Holding(
      id: id,
      fundId: fundId,
      symbol: symbol,
      companyName: companyName,
      category: category,
      instrumentType: instrumentType,
      exchange: exchange,
      quantity: quantity,
      lots: lots,
      lotSize: lotSize,
      averageCost: averageCost,
      ltp: tick.ltp,
      investedValue: investedValue,
      currentValue: nextCurrentValue,
      pnl: nextPnl,
      pnlPercent: investedValue == 0 ? 0 : nextPnl / investedValue * 100,
      marginBlocked: marginBlocked,
      previousClose: previousClose,
      tickSize: tickSize,
    );
  }
}
