import 'dart:convert';

import '../exceptions/trading_data_exception.dart';
import '../models/fund_dto.dart';
import '../models/holding_dto.dart';
import 'json_value_reader.dart';

class TradingDataset {
  const TradingDataset({required this.funds, required this.holdings});

  final List<FundDto> funds;
  final List<HoldingDto> holdings;
}

abstract final class TradingDatasetParser {
  static TradingDataset parse(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        throw const TradingDataException('Dataset root must be an object.');
      }

      final funds = _objects(
        decoded,
        'funds',
      ).map(FundDto.fromJson).toList(growable: false);
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
      return TradingDataset(funds: funds, holdings: holdings);
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
