import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:dashboard/src/heat_map/domain/entities/heat_map_fund.dart';
import 'package:dashboard/src/heat_map/domain/entities/heat_map_layout.dart';
import 'package:dashboard/src/heat_map/domain/layout/squarified_treemap.dart';
import 'package:dashboard/src/heat_map/domain/repositories/heat_map_repository.dart';
import 'package:dashboard/src/heat_map/presentation/bloc/market_heat_map_bloc.dart';
import 'package:dashboard/src/heat_map/presentation/bloc/market_heat_map_event.dart';
import 'package:dashboard/src/heat_map/presentation/bloc/market_heat_map_state.dart';
import 'package:dashboard/src/market/domain/entities/market_category.dart';
import 'package:dashboard/src/market/domain/entities/market_instrument.dart';
import 'package:dashboard/src/market/domain/repositories/market_repository.dart';
import 'package:dashboard/src/market/presentation/bloc/market_bloc.dart';
import 'package:dashboard/src/market/presentation/bloc/market_event.dart';
import 'package:dashboard/src/market/presentation/bloc/market_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SquarifiedTreemap', () {
    test('tile area follows weight and stays inside bounds', () {
      SquarifiedTreemap.resetLayoutCallCount();
      const width = 200.0;
      const height = 100.0;
      final layout = SquarifiedTreemap.layout(
        nodes: const [
          HeatMapWeightedNode(marketKey: 'A', weight: 100),
          HeatMapWeightedNode(marketKey: 'B', weight: 50),
          HeatMapWeightedNode(marketKey: 'C', weight: 25),
        ],
        width: width,
        height: height,
        gap: 1,
      );

      HeatMapCellLayout cell(String key) =>
          layout.cells.singleWhere((item) => item.marketKey == key);
      final areaA = cell('A').areaFactor * width * height;
      final areaB = cell('B').areaFactor * width * height;
      final areaC = cell('C').areaFactor * width * height;
      expect(areaA, greaterThan(areaB));
      expect(areaB, greaterThan(areaC));
      expect(areaA + areaB + areaC, lessThanOrEqualTo(width * height));
      expect(layout.cells, hasLength(3));
    });

    test('same inputs produce the same geometry', () {
      List<HeatMapCellLayout> run() => SquarifiedTreemap.layout(
        nodes: const [
          HeatMapWeightedNode(marketKey: 'A', weight: 100),
          HeatMapWeightedNode(marketKey: 'B', weight: 50),
          HeatMapWeightedNode(marketKey: 'C', weight: 25),
        ],
        width: 320,
        height: 240,
      ).cells;

      expect(run(), run());
    });

    test('orders by weight descending then key, ignoring input order', () {
      final layout = SquarifiedTreemap.layout(
        nodes: const [
          HeatMapWeightedNode(marketKey: 'C', weight: 25),
          HeatMapWeightedNode(marketKey: 'A', weight: 100),
          HeatMapWeightedNode(marketKey: 'B', weight: 50),
        ],
        width: 100,
        height: 100,
      );
      expect(layout.cells.first.marketKey, 'A');
    });
  });

  group('MarketHeatMapBloc', () {
    test('loads equity funds and updates only matching live prices', () async {
      final repository = _HeatRepo([
        _fund('RELIANCE_EQ', 'RELIANCE', 100),
        _fund('TCS_EQ', 'TCS', 80),
      ]);
      final platform = _PricePlatform();
      final bloc = MarketHeatMapBloc(
        repository,
        LivePriceStreamManager(platform),
      )..add(const MarketHeatMapStarted(TradeExchange.nse));
      await bloc.stream.firstWhere(
        (state) => state.status == MarketHeatMapStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.funds, hasLength(2));
      expect(platform.subscriptions.single.toSet(), {
        'RELIANCE_EQ:NSE',
        'TCS_EQ:NSE',
      });

      platform.emit(
        instrumentId: 'TCS_EQ:NSE',
        symbol: 'TCS',
        ltpMinor: 10200,
        sequence: 1,
      );
      await bloc.stream.firstWhere(
        (state) => state.livePrices.containsKey('TCS_EQ:NSE'),
      );

      expect(bloc.state.livePrices.containsKey('RELIANCE_EQ:NSE'), isFalse);
      expect(
        bloc.state.tileLiveDataFor('TCS_EQ:NSE').changePercent,
        closeTo(2, 0.001),
      );
      expect(bloc.state.tileLiveDataFor('RELIANCE_EQ:NSE').ltp, 100);
      expect(repository.calls, 1);
      await bloc.close();
      await platform.close();
    });

    test('exchange change reloads BSE listings and subscriptions', () async {
      final repository = _HeatRepo(
        [_fund('RELIANCE_EQ', 'RELIANCE', 100), _fund('TCS_EQ', 'TCS', 80)],
        bse: [
          _fund('RELIANCE_EQ', 'RELIANCE', 100, exchange: TradeExchange.bse),
          _fund('TCS_EQ', 'TCS', 80, exchange: TradeExchange.bse),
        ],
      );
      final platform = _PricePlatform();
      final bloc = MarketHeatMapBloc(
        repository,
        LivePriceStreamManager(platform),
      )..add(const MarketHeatMapStarted(TradeExchange.nse));
      await bloc.stream.firstWhere(
        (state) => state.status == MarketHeatMapStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);

      bloc.add(const MarketHeatMapExchangeChanged(TradeExchange.bse));
      await bloc.stream.firstWhere(
        (state) =>
            state.status == MarketHeatMapStatus.loaded &&
            state.exchange == TradeExchange.bse,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.funds.every((fund) => fund.exchange == TradeExchange.bse),
        isTrue,
      );
      expect(platform.subscriptions.last.toSet(), {
        'RELIANCE_EQ:BSE',
        'TCS_EQ:BSE',
      });
      expect(repository.calls, 2);
      await bloc.close();
      await platform.close();
    });

    test('shares native subscriptions with MarketBloc', () async {
      final platform = _PricePlatform();
      final manager = LivePriceStreamManager(platform);
      final heatFunds = [
        _fund('RELIANCE_EQ', 'RELIANCE', 100),
        _fund('TCS_EQ', 'TCS', 80),
      ];
      final marketBloc = MarketBloc(_MarketRepo(heatFunds), manager)
        ..add(const MarketStarted());
      await marketBloc.stream.firstWhere(
        (state) => state.status == MarketStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);
      final firstNative = platform.subscriptions.expand((ids) => ids).toSet();

      final heatBloc = MarketHeatMapBloc(_HeatRepo(heatFunds), manager)
        ..add(const MarketHeatMapStarted(TradeExchange.nse));
      await heatBloc.stream.firstWhere(
        (state) => state.status == MarketHeatMapStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);

      final addedAfterHeatMap = platform.subscriptions
          .skip(1)
          .expand((ids) => ids)
          .toSet();
      expect(addedAfterHeatMap.intersection(firstNative), isEmpty);
      await heatBloc.close();
      await marketBloc.close();
      await platform.close();
    });
  });

  group('HeatMapTile rebuild isolation', () {
    test('selector results stay equal for untouched instruments', () {
      final funds = [
        _fund('RELIANCE_EQ', 'RELIANCE', 100),
        _fund('TCS_EQ', 'TCS', 50),
      ];
      final fundsByKey = {for (final fund in funds) fund.marketKey: fund};
      final state = MarketHeatMapState(
        status: MarketHeatMapStatus.loaded,
        funds: funds,
        fundsByKey: fundsByKey,
      );
      final reliance = state.tileLiveDataFor('RELIANCE_EQ:NSE');
      final tcs = state.tileLiveDataFor('TCS_EQ:NSE');
      final next = state.copyWith(
        livePrices: {
          'TCS_EQ:NSE': _liveBatch(
            sequence: 1,
            instrumentId: 'TCS_EQ:NSE',
            symbol: 'TCS',
            ltpMinor: 10200,
          ).updates.single,
        },
      );

      expect(next.tileLiveDataFor('RELIANCE_EQ:NSE'), reliance);
      expect(next.tileLiveDataFor('TCS_EQ:NSE'), isNot(tcs));
      expect(next.tileLiveDataFor('TCS_EQ:NSE').ltp, 102);
      expect(next.tileLiveDataFor('TCS_EQ:NSE').changePercent, 2);
    });

    test('one hundred live ticks do not recompute treemap geometry', () async {
      final repository = _HeatRepo([
        _fund('RELIANCE_EQ', 'RELIANCE', 100),
        _fund('TCS_EQ', 'TCS', 80),
      ]);
      final platform = _PricePlatform();
      final bloc = MarketHeatMapBloc(
        repository,
        LivePriceStreamManager(platform),
      )..add(const MarketHeatMapStarted(TradeExchange.nse));
      await bloc.stream.firstWhere(
        (state) => state.status == MarketHeatMapStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);
      SquarifiedTreemap.resetLayoutCallCount();

      for (var sequence = 1; sequence <= 100; sequence++) {
        bloc.add(
          MarketHeatMapLivePricesReceived(
            _liveBatch(
              sequence: sequence,
              instrumentId: 'TCS_EQ:NSE',
              symbol: 'TCS',
              ltpMinor: 10200 + sequence,
            ),
          ),
        );
      }
      await bloc.stream.firstWhere(
        (state) => (state.livePrices['TCS_EQ:NSE']?.ltpMinor ?? 0) >= 10300,
      );

      expect(SquarifiedTreemap.layoutCallCount, 0);
      expect(bloc.state.tileLiveDataFor('RELIANCE_EQ:NSE').ltp, 100);
      await bloc.close();
      await platform.close();
    });
  });
}

LivePriceBatch _liveBatch({
  required int sequence,
  required String instrumentId,
  required String symbol,
  required int ltpMinor,
  int previousCloseMinor = 10000,
}) => LivePriceBatch(
  sequence: sequence,
  timestamp: DateTime.utc(2026, 8, 24),
  updates: [
    LivePriceTick(
      instrumentId: instrumentId,
      symbol: symbol,
      ltpMinor: ltpMinor,
      previousLtpMinor: previousCloseMinor,
      previousCloseMinor: previousCloseMinor,
      changeMinor: ltpMinor - previousCloseMinor,
      changePercent: (ltpMinor - previousCloseMinor) / previousCloseMinor * 100,
      direction: LivePriceDirection.up,
      timestamp: DateTime.utc(2026, 8, 24),
      sequence: sequence,
    ),
  ],
);

HeatMapFund _fund(
  String id,
  String symbol,
  double weight, {
  TradeExchange exchange = TradeExchange.nse,
  double ltp = 100,
  double previousClose = 100,
}) => HeatMapFund(
  fundId: id,
  exchange: exchange,
  symbol: symbol,
  companyName: symbol,
  heatMapWeight: weight,
  initialLtp: ltp,
  previousClose: previousClose,
  tickSize: 0.05,
);

final class _HeatRepo implements HeatMapRepository {
  _HeatRepo(this.nse, {this.bse});

  final List<HeatMapFund> nse;
  final List<HeatMapFund>? bse;
  int calls = 0;

  @override
  Future<List<HeatMapFund>> getEquityFunds({
    required TradeExchange exchange,
  }) async {
    calls++;
    return exchange == TradeExchange.bse ? (bse ?? nse) : nse;
  }
}

final class _MarketRepo implements MarketRepository {
  _MarketRepo(this.funds);

  final List<HeatMapFund> funds;

  @override
  Future<List<MarketInstrument>> getFunds() async => [
    for (final fund in funds)
      MarketInstrument(
        id: fund.fundId,
        symbol: fund.symbol,
        companyName: fund.companyName,
        category: MarketCategory.equity,
        exchange: fund.exchange,
        ltp: fund.initialLtp,
        change: fund.initialLtp - fund.previousClose,
        changePercent: fund.previousClose == 0
            ? 0
            : (fund.initialLtp - fund.previousClose) / fund.previousClose * 100,
        previousClose: fund.previousClose,
        tickSize: fund.tickSize,
        volume: 1000,
        tags: const [],
        expiryDate: null,
        strikePrice: null,
        optionType: null,
        underlyingSymbol: null,
      ),
  ];
}

final class _PricePlatform implements LivePricePlatformApi {
  final _controller = StreamController<Object?>.broadcast();
  final subscriptions = <List<String>>[];

  @override
  Stream<Object?> get batches => _controller.stream;

  void emit({
    required String instrumentId,
    required String symbol,
    required int ltpMinor,
    required int sequence,
    int previousCloseMinor = 10000,
  }) {
    _controller.add({
      'sequence': sequence,
      'timestamp': 1787460000000,
      'updates': [
        {
          'instrumentId': instrumentId,
          'symbol': symbol,
          'ltpMinor': ltpMinor,
          'previousLtpMinor': previousCloseMinor,
          'previousCloseMinor': previousCloseMinor,
          'changeMinor': ltpMinor - previousCloseMinor,
          'changePercent':
              (ltpMinor - previousCloseMinor) / previousCloseMinor * 100,
          'direction': 'up',
        },
      ],
    });
  }

  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {
    subscriptions.add(instruments.map((item) => item.instrumentId).toList());
  }

  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  Future<void> close() => _controller.close();
}
