import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local API loads and validates the complete trading dataset', () async {
    configureDependencies();
    final api = getIt<TradingLocalApi>();

    final fundsWatch = Stopwatch()..start();
    final funds = await api.getFunds();
    fundsWatch.stop();
    final holdingsWatch = Stopwatch()..start();
    final holdings = await api.getHoldings();
    holdingsWatch.stop();
    final indices = await api.getMarketIndices();

    expect(fundsWatch.elapsedMilliseconds, greaterThanOrEqualTo(790));
    expect(holdingsWatch.elapsedMilliseconds, greaterThanOrEqualTo(790));
    expect(funds, hasLength(39));
    expect(funds.where((fund) => fund.category == 'Equity'), hasLength(10));
    expect(funds.where((fund) => fund.category == 'Future'), hasLength(10));
    expect(funds.where((fund) => fund.category == 'Options'), hasLength(19));
    expect(holdings, hasLength(6));
    expect(
      holdings.where((holding) => holding.category == 'Equity'),
      hasLength(3),
    );
    expect(
      holdings.where((holding) => holding.category == 'Future'),
      hasLength(1),
    );
    expect(
      holdings.where((holding) => holding.category == 'Options'),
      hasLength(2),
    );
    expect(funds.every((fund) => fund.marketDepth.bids.length == 10), isTrue);
    expect(
      funds
          .where((fund) => fund.category == 'Equity')
          .every(
            (fund) => fund.availableExchanges.toSet().containsAll(
              TradeExchange.values,
            ),
          ),
      isTrue,
    );
    expect(indices.map((index) => index.id), [
      'INDEX_NIFTY_50_NSE',
      'INDEX_BANK_NIFTY_NSE',
      'INDEX_SENSEX_BSE',
    ]);
    expect(
      funds.every((fund) => fund.oneMonthPriceHistory.length == 5),
      isTrue,
    );
  });
}
