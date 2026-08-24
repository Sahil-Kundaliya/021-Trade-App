import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import 'fund_bloc_scope.dart';
import 'fund_content.dart';

class FundSheet extends StatelessWidget {
  const FundSheet({
    required this.fundId,
    required this.exchange,
    required this.navigator,
    super.key,
  });
  final String fundId;
  final TradeExchange exchange;
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: DraggableScrollableSheet(
        initialChildSize: 0.84,
        minChildSize: 0.52,
        maxChildSize: 1,
        expand: false,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => Material(
          color: context.appColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                top: false,
                child: FundBlocScope(
                  fundId: fundId,
                  exchange: exchange,
                  child: FundContent(
                    scrollController: scrollController,
                    showDragHandle: true,
                    onBuy: () => _openOrders(TradeSide.buy),
                    onSell: () => _openOrders(TradeSide.sell),
                    onOpenFund: (id, nextExchange) =>
                        navigator.openFund(fundId: id, exchange: nextExchange),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _openOrders(TradeSide side) async {
    await navigator.pop();
    await navigator.openOrders(fundId: fundId, exchange: exchange, side: side);
  }
}
