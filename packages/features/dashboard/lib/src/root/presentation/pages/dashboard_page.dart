import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../market/presentation/bloc/market_bloc.dart';
import '../../../market/presentation/bloc/market_event.dart';
import '../widgets/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<MarketBloc>()..add(const MarketStarted()),
      child: DashboardContent(navigator: navigator),
    );
  }
}
