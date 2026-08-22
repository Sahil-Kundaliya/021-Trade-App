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

    expect(fundsWatch.elapsedMilliseconds, greaterThanOrEqualTo(790));
    expect(holdingsWatch.elapsedMilliseconds, greaterThanOrEqualTo(790));
    expect(funds, hasLength(30));
    expect(funds.where((fund) => fund.category == 'Equity'), hasLength(10));
    expect(funds.where((fund) => fund.category == 'Future'), hasLength(10));
    expect(funds.where((fund) => fund.category == 'Options'), hasLength(10));
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
      funds.every((fund) => fund.oneMonthPriceHistory.length == 5),
      isTrue,
    );
  });
}
