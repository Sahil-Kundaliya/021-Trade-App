import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:core_data/core_data.dart';

import '../../../fund_details/presentation/bloc/fund_details_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_details_event.dart';
import '../../../fund_details/presentation/bloc/fund_chart/fund_chart_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_chart/fund_chart_state.dart';
import '../../../fund_details/presentation/bloc/option_chain/option_chain_bloc.dart';

class FundBlocScope extends StatelessWidget {
  const FundBlocScope({
    required this.fundId,
    required this.exchange,
    required this.child,
    super.key,
  });

  final String fundId;
  final TradeExchange exchange;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => GetIt.instance<FundDetailsBloc>()
          ..add(FundDetailsStarted(fundId: fundId, exchange: exchange)),
      ),
      BlocProvider(
        create: (_) => GetIt.instance<FundChartBloc>()
          ..add(FundChartStarted(fundId: fundId, exchange: exchange)),
      ),
      BlocProvider(create: (_) => GetIt.instance<OptionChainBloc>()),
    ],
    child: child,
  );
}
