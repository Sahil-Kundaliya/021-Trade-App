import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../fund_details/presentation/bloc/fund_details_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_details_event.dart';
import '../widgets/fund_content.dart';

class FundPage extends StatelessWidget {
  const FundPage({required this.fundId, this.navigator, super.key});
  final String fundId;
  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<FundDetailsBloc>()
          ..add(FundDetailsStarted(fundId: fundId)),
    child: Scaffold(
      body: SafeArea(
        child: FundContent(
          onBuy: () =>
              navigator?.openOrders(fundId: fundId, side: TradeSide.buy),
          onSell: () =>
              navigator?.openOrders(fundId: fundId, side: TradeSide.sell),
        ),
      ),
    ),
  );
}
