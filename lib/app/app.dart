import 'package:flutter/material.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigator_impl.dart';
import 'package:zero_two_one_trade_assignment/app/router/app_router.dart';

class TradingApp extends StatelessWidget {
  factory TradingApp({Key? key, AppRouter? router}) {
    final appRouter = router ?? AppRouter();
    return TradingApp._(
      key: key,
      router: appRouter,
      navigator: AppNavigatorImpl(appRouter),
    );
  }

  const TradingApp._({
    super.key,
    required this.router,
    required this.navigator,
  });

  final AppRouter router;
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '021 Trade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router.config(),
    );
  }
}
