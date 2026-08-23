import '../../market/market_instrument_key.dart';
import '../../market/trade_exchange.dart';

enum PortfolioCategory { equity, future, options }

/// An ownership position rebuilt from successfully executed orders.
class DerivedPosition {
  const DerivedPosition({
    required this.fundId,
    required this.exchange,
    required this.symbol,
    required this.companyName,
    required this.instrumentType,
    required this.category,
    required this.quantity,
    required this.averageCost,
    required this.lotSize,
    required this.openedAt,
    required this.updatedAt,
    required this.staticLtp,
    required this.previousClose,
    required this.tickSize,
  });

  final String fundId;
  final TradeExchange exchange;
  final String symbol;
  final String companyName;
  final String instrumentType;
  final PortfolioCategory category;
  final int quantity;
  final double averageCost;
  final int lotSize;
  final DateTime openedAt;
  final DateTime updatedAt;
  final double staticLtp;
  final double previousClose;
  final double tickSize;

  String get marketKey =>
      MarketInstrumentKey(fundId: fundId, exchange: exchange).value;
  int? get lots => lotSize > 1 ? quantity ~/ lotSize : null;
}
