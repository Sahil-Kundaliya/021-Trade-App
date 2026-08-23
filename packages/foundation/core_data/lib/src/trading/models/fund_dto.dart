import '../parsing/json_value_reader.dart';
import 'market_depth_dto.dart';
import 'price_history_point_dto.dart';
import 'price_candle_dto.dart';
import 'fund_activity_dto.dart';
import 'fund_collateral_dto.dart';
import 'fund_margin_dto.dart';
import 'fund_exchange_listing_dto.dart';
import 'market_depth_level_dto.dart';
import '../../market/trade_exchange.dart';

class FundDto {
  const FundDto({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.category,
    required this.instrumentType,
    required this.currency,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.tickSize,
    required this.lotSize,
    required this.expiryDate,
    required this.strikePrice,
    required this.optionType,
    required this.underlyingSymbol,
    required this.openInterest,
    required this.impliedVolatility,
    required this.tags,
    required this.marketDepth,
    required this.oneMonthPriceHistory,
    required this.threeMonthPriceHistory,
    required this.marginDetails,
    required this.collateralDetails,
    required this.recentActivity,
    this.listings = const [],
    this.intradayCandles = const [],
  });

  factory FundDto.fromJson(Map<String, dynamic> json) {
    final history = JsonValueReader.object(json, 'priceHistory');
    List<PriceHistoryPointDto> historyPoints(String key) =>
        JsonValueReader.list(history, key)
            .asMap()
            .entries
            .map(
              (entry) => PriceHistoryPointDto.fromJson(
                JsonValueReader.listObject(
                  entry.value,
                  'priceHistory.$key[${entry.key}]',
                ),
              ),
            )
            .toList(growable: false);
    final rawTags = JsonValueReader.list(json, 'tags');
    final tags = rawTags
        .asMap()
        .entries
        .map((entry) {
          final value = entry.value;
          if (value is String && value.isNotEmpty) return value;
          throw FormatException('Invalid tag at tags[${entry.key}].');
        })
        .toList(growable: false);

    return FundDto(
      id: JsonValueReader.string(json, 'id'),
      symbol: JsonValueReader.string(json, 'symbol'),
      companyName: JsonValueReader.string(json, 'companyName'),
      exchange: JsonValueReader.string(json, 'exchange'),
      category: JsonValueReader.string(json, 'category'),
      instrumentType: JsonValueReader.string(json, 'instrumentType'),
      currency: JsonValueReader.string(json, 'currency'),
      ltp: JsonValueReader.number(json, 'ltp'),
      previousClose: JsonValueReader.number(json, 'previousClose'),
      change: JsonValueReader.number(json, 'change'),
      changePercent: JsonValueReader.number(json, 'changePercent'),
      open: JsonValueReader.number(json, 'open'),
      high: JsonValueReader.number(json, 'high'),
      low: JsonValueReader.number(json, 'low'),
      volume: JsonValueReader.integer(json, 'volume'),
      tickSize: JsonValueReader.number(json, 'tickSize'),
      lotSize: JsonValueReader.integer(json, 'lotSize'),
      expiryDate: JsonValueReader.nullableDate(json, 'expiryDate'),
      strikePrice: JsonValueReader.nullableNumber(json, 'strikePrice'),
      optionType: JsonValueReader.nullableString(json, 'optionType'),
      underlyingSymbol: JsonValueReader.nullableString(
        json,
        'underlyingSymbol',
      ),
      openInterest: JsonValueReader.nullableInteger(json, 'openInterest'),
      impliedVolatility: JsonValueReader.nullableNumber(
        json,
        'impliedVolatility',
      ),
      tags: tags,
      marketDepth: MarketDepthDto.fromJson(
        JsonValueReader.object(json, 'marketDepth'),
      ),
      oneMonthPriceHistory: historyPoints('oneMonth'),
      threeMonthPriceHistory: historyPoints('threeMonths'),
      marginDetails: FundMarginDto.fromJson(
        JsonValueReader.object(json, 'marginDetails'),
      ),
      collateralDetails: FundCollateralDto.fromJson(
        JsonValueReader.object(json, 'collateralDetails'),
      ),
      recentActivity: JsonValueReader.list(json, 'recentActivity')
          .asMap()
          .entries
          .map(
            (entry) => FundActivityDto.fromJson(
              JsonValueReader.listObject(
                entry.value,
                'recentActivity[${entry.key}]',
              ),
            ),
          )
          .toList(growable: false),
      intradayCandles: JsonValueReader.optionalList(json, 'intradayCandles')
          .asMap()
          .entries
          .map(
            (entry) => PriceCandleDto.fromJson(
              JsonValueReader.listObject(
                entry.value,
                'intradayCandles[${entry.key}]',
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String symbol;
  final String companyName;
  final String exchange;
  final String category;
  final String instrumentType;
  final String currency;
  final double ltp;
  final double previousClose;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final int volume;
  final double tickSize;
  final int lotSize;
  final DateTime? expiryDate;
  final double? strikePrice;
  final String? optionType;
  final String? underlyingSymbol;
  final int? openInterest;
  final double? impliedVolatility;
  final List<String> tags;
  final MarketDepthDto marketDepth;
  final List<PriceHistoryPointDto> oneMonthPriceHistory;
  final List<PriceHistoryPointDto> threeMonthPriceHistory;
  final FundMarginDto marginDetails;
  final FundCollateralDto collateralDetails;
  final List<FundActivityDto> recentActivity;
  final List<FundExchangeListingDto> listings;
  final List<PriceCandleDto> intradayCandles;

  List<TradeExchange> get availableExchanges => listings
      .map((listing) => listing.exchange)
      .toSet()
      .toList(growable: false);

  FundExchangeListingDto? listingFor(TradeExchange exchange) {
    for (final listing in listings) {
      if (listing.exchange == exchange) return listing;
    }
    return null;
  }

  FundDto withListings(List<FundExchangeListingDto> value) =>
      _copy(listings: List<FundExchangeListingDto>.unmodifiable(value));

  FundDto forExchange(TradeExchange value) {
    final listing = listingFor(value);
    if (listing == null) {
      throw StateError('$id is not listed on ${value.code}.');
    }
    return _copy(
      exchange: value.code,
      ltp: listing.ltp,
      previousClose: listing.previousClose,
      change: listing.change,
      changePercent: listing.changePercent,
      open: listing.open,
      high: listing.high,
      low: listing.low,
      volume: listing.volume,
      tickSize: listing.tickSize,
      marketDepth: _depthFor(listing),
      intradayCandles: listing.intradayCandles,
    );
  }

  MarketDepthDto _depthFor(FundExchangeListingDto listing) {
    if (listing.exchange == TradeExchange.parse(exchange)) return marketDepth;
    double shifted(double price) {
      final raw = price + (listing.ltp - ltp);
      return (raw / listing.tickSize).round() * listing.tickSize;
    }

    List<MarketDepthLevelDto> levels(List<MarketDepthLevelDto> source) => source
        .map(
          (level) => MarketDepthLevelDto(
            price: shifted(level.price),
            quantity: level.quantity,
            orderCount: level.orderCount,
          ),
        )
        .toList(growable: false);
    return MarketDepthDto(
      bids: levels(marketDepth.bids),
      asks: levels(marketDepth.asks),
      totalBidQuantity: marketDepth.totalBidQuantity,
      totalAskQuantity: marketDepth.totalAskQuantity,
      updatedAt: marketDepth.updatedAt,
    );
  }

  FundDto _copy({
    String? exchange,
    double? ltp,
    double? previousClose,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    int? volume,
    double? tickSize,
    List<FundExchangeListingDto>? listings,
    MarketDepthDto? marketDepth,
    List<PriceCandleDto>? intradayCandles,
  }) => FundDto(
    id: id,
    symbol: symbol,
    companyName: companyName,
    exchange: exchange ?? this.exchange,
    category: category,
    instrumentType: instrumentType,
    currency: currency,
    ltp: ltp ?? this.ltp,
    previousClose: previousClose ?? this.previousClose,
    change: change ?? this.change,
    changePercent: changePercent ?? this.changePercent,
    open: open ?? this.open,
    high: high ?? this.high,
    low: low ?? this.low,
    volume: volume ?? this.volume,
    tickSize: tickSize ?? this.tickSize,
    lotSize: lotSize,
    expiryDate: expiryDate,
    strikePrice: strikePrice,
    optionType: optionType,
    underlyingSymbol: underlyingSymbol,
    openInterest: openInterest,
    impliedVolatility: impliedVolatility,
    tags: tags,
    marketDepth: marketDepth ?? this.marketDepth,
    oneMonthPriceHistory: oneMonthPriceHistory,
    threeMonthPriceHistory: threeMonthPriceHistory,
    marginDetails: marginDetails,
    collateralDetails: collateralDetails,
    recentActivity: recentActivity,
    listings: listings ?? this.listings,
    intradayCandles: intradayCandles ?? this.intradayCandles,
  );
}
