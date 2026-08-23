import 'dart:convert';

import '../exceptions/trading_data_exception.dart';
import '../models/fund_dto.dart';
import '../models/holding_dto.dart';
import '../models/fund_exchange_listing_dto.dart';
import '../models/market_index_dto.dart';
import '../../market/trade_exchange.dart';
import 'json_value_reader.dart';

class TradingDataset {
  const TradingDataset({
    required this.funds,
    required this.holdings,
    required this.indices,
  });

  final List<FundDto> funds;
  final List<HoldingDto> holdings;
  final List<MarketIndexDto> indices;
}

abstract final class TradingDatasetParser {
  static TradingDataset parse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        throw const TradingDataException('Dataset root must be an object.');
      }

      final baseFunds = _objects(
        decoded,
        'funds',
      ).map(FundDto.fromJson).toList(growable: false);
      final additionalListings = decoded['marketListings'] == null
          ? const <FundExchangeListingDto>[]
          : _objects(
              decoded,
              'marketListings',
            ).map(FundExchangeListingDto.fromJson).toList(growable: false);
      final funds = baseFunds
          .map((fund) {
            final primary = FundExchangeListingDto(
              fundId: fund.id,
              exchange: TradeExchange.parse(fund.exchange),
              ltp: fund.ltp,
              previousClose: fund.previousClose,
              open: fund.open,
              high: fund.high,
              low: fund.low,
              volume: fund.volume,
              tickSize: fund.tickSize,
              intradayCandles: fund.intradayCandles,
            );
            final listings = <FundExchangeListingDto>[
              primary,
              ...additionalListings.where(
                (listing) => listing.fundId == fund.id,
              ),
            ];
            return fund.withListings(listings);
          })
          .toList(growable: false);
      final fundsById = {for (final fund in funds) fund.id: fund};
      final holdings = _objects(decoded, 'holdings')
          .map((json) {
            final fundId = JsonValueReader.string(json, 'fundId');
            final fund = fundsById[fundId];
            if (fund == null) {
              throw TradingDataException(
                'Holding references unknown fund $fundId.',
              );
            }
            return HoldingDto.fromJson(json, companyName: fund.companyName);
          })
          .toList(growable: false);
      final indices = decoded['indices'] == null
          ? const <MarketIndexDto>[]
          : _objects(
              decoded,
              'indices',
            ).map(MarketIndexDto.fromJson).toList(growable: false);
      return TradingDataset(funds: funds, holdings: holdings, indices: indices);
    } on TradingDataException {
      rethrow;
    } on FormatException catch (error) {
      throw TradingDataException('Invalid trading JSON: ${error.message}');
    } on Object catch (error) {
      throw TradingDataException('Malformed trading dataset: $error');
    }
  }

  static Iterable<Map<String, dynamic>> _objects(
    Map<String, dynamic> json,
    String key,
  ) sync* {
    final values = JsonValueReader.list(json, key);
    for (var index = 0; index < values.length; index++) {
      yield JsonValueReader.listObject(values[index], '$key[$index]');
    }
  }
}
