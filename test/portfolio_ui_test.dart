import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/src/holdings/domain/entities/holding.dart';
import 'package:portfolio/src/holdings/domain/repositories/holdings_repository.dart';
import 'package:portfolio/src/holdings/presentation/bloc/holdings_bloc.dart';
import 'package:portfolio/src/holdings/presentation/bloc/holdings_event.dart';
import 'package:portfolio/src/holdings/presentation/widgets/holdings_list.dart';
import 'package:portfolio/src/root/presentation/widgets/portfolio_content.dart';
import 'package:navigation_contract/navigation_contract.dart';

void main() {
  Future<void> finishLoading(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  }

  Future<void> pumpPortfolio(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    bool privacyMode = false,
    AppNavigator? navigator,
    HoldingsRepository? repository,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: BlocProvider(
        create: (_) => HoldingsBloc(
          repository ?? _EmptyRepository(),
          LivePriceStreamManager(_PricePlatform()),
        )..add(const HoldingsStarted()),
        child: PrivacyModeScope(
          enabled: privacyMode,
          child: PortfolioContent(navigator: navigator),
        ),
      ),
    ),
  );

  testWidgets('fresh order book shows an empty portfolio without tabs', (
    tester,
  ) async {
    final navigator = _Navigator();
    await pumpPortfolio(tester, navigator: navigator);
    await finishLoading(tester);

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('No holdings'), findsOneWidget);
    expect(find.text('Portfolio Value'), findsNothing);
    expect(find.text('Equity'), findsNothing);
    expect(find.text('Futures'), findsNothing);
    expect(find.text('Options'), findsNothing);
    expect(find.text('RELIANCE'), findsNothing);
    expect(find.text('Explore'), findsOneWidget);
    final viewportCenter =
        tester.view.physicalSize.height / tester.view.devicePixelRatio / 2;
    expect(
      (tester.getCenter(find.byType(AppEmptyState)).dy - viewportCenter).abs(),
      lessThan(80),
    );

    await tester.tap(find.text('Explore'));
    await tester.pump();
    expect(navigator.searchCalls, 1);
  });

  testWidgets('centers the portfolio error state in the available section', (
    tester,
  ) async {
    await pumpPortfolio(tester, repository: _ErrorRepository());
    await finishLoading(tester);

    expect(find.text('Unable to load holdings'), findsOneWidget);
    final viewportCenter =
        tester.view.physicalSize.height / tester.view.devicePixelRatio / 2;
    expect(
      (tester.getCenter(find.byType(AppEmptyState)).dy - viewportCenter).abs(),
      lessThan(80),
    );
  });

  testWidgets('renders empty state safely on a narrow dark screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPortfolio(tester, themeMode: ThemeMode.dark);
    await finishLoading(tester);

    expect(find.text('No holdings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty portfolio remains safe under privacy mode', (
    tester,
  ) async {
    await pumpPortfolio(tester, privacyMode: true);
    await finishLoading(tester);

    expect(find.text('No holdings'), findsOneWidget);
    expect(find.text('RELIANCE'), findsNothing);
  });

  testWidgets('shows the standardized empty holdings state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: HoldingsList(holdings: [])),
      ),
    );

    expect(find.text('No holdings'), findsOneWidget);
    expect(
      find.text('Your successfully executed buy orders will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

final class _Navigator implements AppNavigator {
  int searchCalls = 0;

  @override
  Future<void> openSearch() async => searchCalls++;
  @override
  void goToDashboard() {}
  @override
  void goToPortfolio() {}
  @override
  void goToProfile() {}
  @override
  void goToWatchlist() {}
  @override
  Future<void> openFund({
    required String fundId,
    required TradeExchange exchange,
  }) async {}
  @override
  Future<void> openLicenceInformation() async {}
  @override
  Future<void> openOrderBook() async {}
  @override
  Future<void> openOrders({
    required String fundId,
    required TradeExchange exchange,
    TradeSide? side,
  }) async {}
  @override
  Future<void> pop() async {}
}

final class _EmptyRepository implements HoldingsRepository {
  @override
  Stream<List<Holding>> get holdingChanges => const Stream.empty();
  @override
  Future<List<Holding>> getHoldings() async => const [];
}

final class _ErrorRepository implements HoldingsRepository {
  @override
  Stream<List<Holding>> get holdingChanges => const Stream.empty();
  @override
  Future<List<Holding>> getHoldings() async => throw StateError('failed');
}

final class _PricePlatform implements LivePricePlatformApi {
  final _batches = StreamController<Object?>.broadcast();
  @override
  Stream<Object?> get batches => _batches.stream;
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {}
  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {}
}
