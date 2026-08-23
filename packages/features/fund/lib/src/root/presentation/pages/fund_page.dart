import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../widgets/fund_bloc_scope.dart';
import '../widgets/fund_content.dart';

class FundPage extends StatelessWidget {
  const FundPage({
    required this.fundId,
    this.exchange = TradeExchange.nse,
    this.navigator,
    super.key,
  });
  final String fundId;
  final TradeExchange exchange;
  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) => FundBlocScope(
    fundId: fundId,
    exchange: exchange,
    child: Scaffold(
      body: SafeArea(
        child: FundContent(
          onBuy: () => navigator?.openOrders(
            fundId: fundId,
            exchange: exchange,
            side: TradeSide.buy,
          ),
          onSell: () => navigator?.openOrders(
            fundId: fundId,
            exchange: exchange,
            side: TradeSide.sell,
          ),
          onOpenFund: (id, nextExchange) => navigator?.openFund(
            fundId: id,
            exchange: nextExchange,
          ),
        ),
      ),
    ),
  );
}
