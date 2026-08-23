import 'package:core_data/core_data.dart';
import 'package:core_data/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:search/src/fund_search/data/repositories/search_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns every local exchange-aware instrument listing', () async {
    final getIt = GetIt.asNewInstance();
    registerCoreDataDependencies(getIt);
    final repository = SearchRepositoryImpl(getIt<TradingLocalApi>());

    final funds = await repository.getFunds();

    expect(funds, hasLength(49));
    expect(funds.map((fund) => fund.id).toSet(), hasLength(39));
    expect(
      funds
          .where((fund) => fund.id == 'RELIANCE_EQ')
          .map((fund) => fund.exchange),
      containsAll([TradeExchange.nse, TradeExchange.bse]),
    );
    expect(funds.map((fund) => fund.marketKey).toSet(), hasLength(49));
  });
}
