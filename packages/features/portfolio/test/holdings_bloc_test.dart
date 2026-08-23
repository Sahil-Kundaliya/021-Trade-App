import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/src/holdings/domain/entities/holding.dart';
import 'package:portfolio/src/holdings/domain/repositories/holdings_repository.dart';
import 'package:portfolio/src/holdings/presentation/bloc/holdings_bloc.dart';
import 'package:portfolio/src/holdings/presentation/bloc/holdings_event.dart';
import 'package:portfolio/src/holdings/presentation/bloc/holdings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('live ticks update one holding and the portfolio aggregate', () async {
    final platform = _PricePlatform();
    final bloc = HoldingsBloc(_Repository(), LivePriceStreamManager(platform))
      ..add(const HoldingsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == HoldingsStatus.loaded,
    );

    platform.emit(ltpMinor: 11000, previousLtpMinor: 10000, sequence: 1);
    await bloc.stream.firstWhere(
      (state) =>
          state.holdings.singleWhere((item) => item.fundId == 'A').ltp == 110,
    );
    final first = bloc.state.holdings.singleWhere((item) => item.fundId == 'A');
    expect((first.currentValue, first.pnl, first.pnlPercent), (1100, 100, 10));
    expect(bloc.state.summary!.currentValue, 3100);
    expect(bloc.state.summary!.totalPnl, 100);

    platform.emit(ltpMinor: 10500, previousLtpMinor: 11000, sequence: 2);
    await bloc.stream.firstWhere(
      (state) =>
          state.holdings.singleWhere((item) => item.fundId == 'A').ltp == 105,
    );
    final second = bloc.state.holdings.singleWhere(
      (item) => item.fundId == 'A',
    );
    expect((second.currentValue, second.pnl, second.pnlPercent), (1050, 50, 5));
    expect(
      bloc.state.holdings.singleWhere((item) => item.fundId == 'B').ltp,
      200,
    );
    expect(bloc.state.summary!.currentValue, 3050);
    expect(bloc.state.summary!.totalPnl, 50);
    await bloc.close();
    await platform.close();
  });

  test('categories are dynamic and invalid selection falls back', () async {
    final repository = _ReactiveRepository([
      _holding('A', 10, 100),
      _holding('OPT', 750, 10, category: PortfolioCategory.options),
    ]);
    final platform = _PricePlatform();
    final bloc = HoldingsBloc(repository, LivePriceStreamManager(platform))
      ..add(const HoldingsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == HoldingsStatus.loaded,
    );
    expect(bloc.state.availableCategories, [
      PortfolioCategory.equity,
      PortfolioCategory.options,
    ]);

    bloc.add(const HoldingsCategoryChanged(PortfolioCategory.options));
    await bloc.stream.firstWhere(
      (state) => state.selectedCategory == PortfolioCategory.options,
    );
    expect(bloc.state.visibleHoldings.single.fundId, 'OPT');

    repository.emit([_holding('A', 10, 100)]);
    await bloc.stream.firstWhere(
      (state) =>
          state.availableCategories.length == 1 &&
          state.selectedCategory == PortfolioCategory.equity,
    );
    expect(bloc.state.visibleHoldings.single.fundId, 'A');
    await bloc.close();
    await repository.close();
    await platform.close();
  });
}

final class _Repository implements HoldingsRepository {
  @override
  Stream<List<Holding>> get holdingChanges => const Stream.empty();

  @override
  Future<List<Holding>> getHoldings() async => [
    _holding('A', 10, 100),
    _holding('B', 10, 200),
  ];
}

final class _ReactiveRepository implements HoldingsRepository {
  _ReactiveRepository(this.current);
  List<Holding> current;
  final _controller = StreamController<List<Holding>>.broadcast();

  @override
  Stream<List<Holding>> get holdingChanges => _controller.stream;
  @override
  Future<List<Holding>> getHoldings() async => current;

  void emit(List<Holding> holdings) {
    current = holdings;
    _controller.add(holdings);
  }

  Future<void> close() => _controller.close();
}

Holding _holding(
  String id,
  int quantity,
  double price, {
  PortfolioCategory category = PortfolioCategory.equity,
}) => Holding(
  id: id,
  fundId: id,
  symbol: id,
  companyName: id,
  category: category,
  instrumentType: 'EQUITY',
  exchange: 'NSE',
  quantity: quantity,
  lots: null,
  lotSize: 1,
  averageCost: price,
  ltp: price,
  investedValue: quantity * price,
  currentValue: quantity * price,
  pnl: 0,
  pnlPercent: 0,
  marginBlocked: 0,
  previousClose: price,
  tickSize: .05,
);

final class _PricePlatform implements LivePricePlatformApi {
  final _controller = StreamController<Object?>.broadcast();
  @override
  Stream<Object?> get batches => _controller.stream;

  void emit({
    required int ltpMinor,
    required int previousLtpMinor,
    required int sequence,
  }) {
    _controller.add({
      'sequence': sequence,
      'timestamp': 1787460000000,
      'updates': [
        {
          'instrumentId': 'A',
          'symbol': 'A',
          'ltpMinor': ltpMinor,
          'previousLtpMinor': previousLtpMinor,
          'previousCloseMinor': 10000,
          'changeMinor': ltpMinor - 10000,
          'changePercent': (ltpMinor - 10000) / 100,
          'direction': ltpMinor >= previousLtpMinor ? 'up' : 'down',
        },
      ],
    });
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {}
  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {}
  Future<void> close() => _controller.close();
}
