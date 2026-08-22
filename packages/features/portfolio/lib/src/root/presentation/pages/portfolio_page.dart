import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../holdings/presentation/bloc/holdings_bloc.dart';
import '../../../holdings/presentation/bloc/holdings_event.dart';
import '../widgets/portfolio_content.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<HoldingsBloc>()..add(const HoldingsStarted()),
      child: PortfolioContent(navigator: navigator),
    );
  }
}
