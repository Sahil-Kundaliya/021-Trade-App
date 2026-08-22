import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../widgets/fund_content.dart';

class FundPage extends StatelessWidget {
  const FundPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FundContent(
          onBuy: navigator?.openOrders ?? _noOp,
          onSell: navigator?.openOrders ?? _noOp,
        ),
      ),
    );
  }

  static void _noOp() {}
}
