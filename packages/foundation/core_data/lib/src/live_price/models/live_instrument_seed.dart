import '../../market/trade_exchange.dart';

enum LiveMarketAssetType { equity, future, option, marketIndex }

class LiveInstrumentSeed {
  const LiveInstrumentSeed({
    String? marketKey,
    String? instrumentId,
    String? fundId,
    this.exchange = TradeExchange.nse,
    this.assetType = LiveMarketAssetType.equity,
    required this.symbol,
    required this.ltpMinor,
    required this.previousCloseMinor,
    required this.tickSizeMinor,
  }) : assert(marketKey != null || instrumentId != null),
       marketKey = marketKey ?? instrumentId ?? '',
       fundId = fundId ?? instrumentId ?? marketKey ?? '';

  factory LiveInstrumentSeed.fromPrices({
    String? marketKey,
    String? instrumentId,
    String? fundId,
    TradeExchange exchange = TradeExchange.nse,
    LiveMarketAssetType assetType = LiveMarketAssetType.equity,
    required String symbol,
    required double ltp,
    required double previousClose,
    required double tickSize,
  }) => LiveInstrumentSeed(
    marketKey: marketKey,
    instrumentId: instrumentId,
    fundId: fundId,
    exchange: exchange,
    assetType: assetType,
    symbol: symbol,
    ltpMinor: (ltp * 100).round(),
    previousCloseMinor: (previousClose * 100).round(),
    tickSizeMinor: (tickSize * 100).round().clamp(1, 1 << 31),
  );

  final String marketKey;
  final String fundId;
  final TradeExchange exchange;
  final LiveMarketAssetType assetType;
  final String symbol;
  final int ltpMinor;
  final int previousCloseMinor;
  final int tickSizeMinor;

  /// Backwards-compatible protocol name. Its value is the exchange-aware key.
  String get instrumentId => marketKey;

  Map<String, Object> toMessage() => {
    'marketKey': marketKey,
    'instrumentId': marketKey,
    'fundId': fundId,
    'exchange': exchange.code,
    'assetType': assetType.name,
    'symbol': symbol,
    'ltpMinor': ltpMinor,
    'previousCloseMinor': previousCloseMinor,
    'tickSizeMinor': tickSizeMinor,
  };
}
