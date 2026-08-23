import 'package:core_ui/core_ui.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigation_scope.dart';
import 'package:zero_two_one_trade_assignment/app/navigation/app_navigator_impl.dart';
import 'package:zero_two_one_trade_assignment/app/router/app_router.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';
import 'package:zero_two_one_trade_assignment/app/preferences/app_preferences_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/app_connectivity_lifecycle.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_event.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<AppPreferencesBloc>()..add(const AppPreferencesStarted()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<ConnectivityBloc>()..add(const ConnectivityStarted()),
        ),
      ],
      child: AppConnectivityLifecycle(
        child: BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
          buildWhen: (previous, current) =>
              previous.preferences.themeMode != current.preferences.themeMode,
          builder: (context, state) => AppNavigationScope(
            navigator: navigator,
            child: MaterialApp.router(
              title: '021 Trade',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _flutterThemeMode(state.preferences.themeMode),
              themeAnimationDuration: AppMotion.medium,
              routerConfig: router.config(),
              builder: (context, child) =>
                  BlocListener<AppPreferencesBloc, AppPreferencesState>(
                    listenWhen: (previous, current) =>
                        previous.errorMessage != current.errorMessage &&
                        current.errorMessage != null,
                    listener: (context, state) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    },
                    child: child ?? const SizedBox.shrink(),
                  ),
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
