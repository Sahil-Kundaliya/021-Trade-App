import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../exceptions/trading_data_exception.dart';
import '../models/fund_dto.dart';
import '../models/holding_dto.dart';
import '../parsing/trading_dataset_parser.dart';
import 'trading_local_api.dart';

@LazySingleton(as: TradingLocalApi)
final class TradingLocalApiImpl implements TradingLocalApi {
  static const _assetPath =
      'packages/core_data/assets/mock/trading_mock_dataset.json';
  static const _requestDelay = Duration(milliseconds: 800);

  Future<TradingDataset>? _datasetFuture;

  @override
  Future<List<FundDto>> getFunds() async {
    await Future<void>.delayed(_requestDelay);
    final dataset = await _loadDataset();
    return List<FundDto>.unmodifiable(dataset.funds);
  }

  @override
  Future<List<HoldingDto>> getHoldings() async {
    await Future<void>.delayed(_requestDelay);
    final dataset = await _loadDataset();
    return List<HoldingDto>.unmodifiable(dataset.holdings);
  }

  Future<TradingDataset> _loadDataset() {
    return _datasetFuture ??= _readAndParseDataset();
  }

  Future<TradingDataset> _readAndParseDataset() async {
    try {
      final source = await rootBundle.loadString(_assetPath);
      return TradingDatasetParser.parse(source);
    } on TradingDataException {
      rethrow;
    } on FlutterError catch (error) {
      throw TradingDataException('Unable to load $_assetPath: $error');
    } on Object catch (error) {
      throw TradingDataException('Unable to load trading dataset: $error');
    }
  }
}
