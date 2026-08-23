import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigation_scope.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigator_impl.dart';
import 'package:zero_two_one_trade_assignment/app/router/app_router.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';
import 'package:zero_two_one_trade_assignment/app/theme/theme_bloc.dart';

class TradingApp extends StatelessWidget {
  factory TradingApp({Key? key, AppRouter? router}) {
    configureDependencies();
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
    return BlocProvider(
      create: (_) => getIt<ThemeBloc>()..add(const ThemeStarted()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) => AppNavigationScope(
          navigator: navigator,
          child: MaterialApp.router(
            title: '021 Trade',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _flutterThemeMode(state.mode),
            themeAnimationDuration: AppDurations.normal,
            routerConfig: router.config(),
            builder: (context, child) => BlocListener<ThemeBloc, ThemeState>(
              listenWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null,
              listener: (context, state) {
                ScaffoldMessenger.maybeOf(
                  context,
                )?.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              },
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

ThemeMode _flutterThemeMode(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};
