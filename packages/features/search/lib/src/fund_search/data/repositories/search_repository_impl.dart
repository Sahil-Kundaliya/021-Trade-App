import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/searchable_fund.dart';
import '../../domain/repositories/search_repository.dart';
import '../mappers/search_fund_mapper.dart';

@LazySingleton(as: SearchRepository)
final class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;

  @override
  Future<List<SearchableFund>> getFunds() async {
    final funds = await _tradingLocalApi.getFunds();
    return List<SearchableFund>.unmodifiable(
      funds.expand(
        (fund) => fund.availableExchanges.map(
          (exchange) => SearchFundMapper.toDomain(fund.forExchange(exchange)),
        ),
      ),
    );
  }
}
