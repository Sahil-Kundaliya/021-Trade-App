import '../parsing/json_value_reader.dart';
import 'market_depth_dto.dart';
import 'price_history_point_dto.dart';
import 'fund_activity_dto.dart';
import 'fund_collateral_dto.dart';
import 'fund_margin_dto.dart';

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
}
