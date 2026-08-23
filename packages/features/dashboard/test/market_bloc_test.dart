import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:dashboard/src/market/domain/entities/market_category.dart';
import 'package:dashboard/src/market/domain/entities/market_instrument.dart';
import 'package:dashboard/src/market/domain/repositories/market_repository.dart';
import 'package:dashboard/src/market/presentation/bloc/market_bloc.dart';
import 'package:dashboard/src/market/presentation/bloc/market_event.dart';
import 'package:dashboard/src/market/presentation/bloc/market_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'live changes rerank gainers and move dynamic tags without refetching',
    () async {
      final repository = _Repository();
      final platform = _PricePlatform();
      final bloc = MarketBloc(repository, LivePriceStreamManager(platform))
        ..add(const MarketStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == MarketStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.visibleFunds.map((item) => item.id), ['B', 'A', 'C']);
      expect(platform.subscriptions.single.toSet(), {
        'A:NSE',
        'B:NSE',
        'C:NSE',
      });

      platform.emitA(ltpMinor: 10300);
      await bloc.stream.firstWhere(
        (state) => state.visibleFunds.first.id == 'A',
      );

      expect(bloc.state.visibleFunds.map((item) => item.id), ['A', 'B', 'C']);
      final a = bloc.state.allFunds.singleWhere((item) => item.id == 'A');
      expect(a.tags, containsAll(['Recommended', 'Top Gainer']));
      expect(repository.calls, 1);
      await bloc.close();
      await platform.close();
    },
  );

  test(
    'exchange change filters and replaces the scanner lease without refetching',
    () async {
      final repository = _ExchangeRepository();
      final platform = _PricePlatform();
      final bloc = MarketBloc(repository, LivePriceStreamManager(platform))
        ..add(const MarketStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == MarketStatus.loaded,
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.selectedExchange, TradeExchange.nse);
      expect(
        bloc.state.visibleFunds.every(
          (fund) => fund.exchange == TradeExchange.nse,
        ),
        isTrue,
      );

      bloc.add(const MarketExchangeChanged(TradeExchange.bse));
      await bloc.stream.firstWhere(
        (state) => state.selectedExchange == TradeExchange.bse,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.visibleFunds.every(
          (fund) => fund.exchange == TradeExchange.bse,
        ),
        isTrue,
      );
      expect(platform.subscriptions.last.toSet(), {'A:BSE', 'B:BSE'});
      expect(repository.calls, 1);
      await bloc.close();
      await platform.close();
    },
  );
}

final class _Repository implements MarketRepository {
  int calls = 0;
  @override
  Future<List<MarketInstrument>> getFunds() async {
    calls++;
    return [
      _fund('A', 101, const ['Recommended']),
      _fund('B', 102, const ['Top Gainer']),
      _fund('C', 100.5, const ['Dividend']),
    ];
  }
}

final class _ExchangeRepository implements MarketRepository {
  int calls = 0;

  @override
  Future<List<MarketInstrument>> getFunds() async {
    calls++;
    return [
      _fund('A', 101, const [], exchange: TradeExchange.nse),
      _fund('B', 102, const [], exchange: TradeExchange.nse),
      _fund('A', 99, const [], exchange: TradeExchange.bse),
      _fund('B', 104, const [], exchange: TradeExchange.bse),
    ];
  }
}

MarketInstrument _fund(
  String id,
  double ltp,
  List<String> tags, {
  TradeExchange exchange = TradeExchange.nse,
}) => MarketInstrument(
  id: id,
  symbol: id,
  companyName: id,
  category: MarketCategory.equity,
  exchange: exchange,
  ltp: ltp,
  change: ltp - 100,
  changePercent: ltp - 100,
  previousClose: 100,
  tickSize: .05,
  volume: 1000,
  tags: tags,
  expiryDate: null,
  strikePrice: null,
  optionType: null,
  underlyingSymbol: null,
);

final class _PricePlatform implements LivePricePlatformApi {
  final _controller = StreamController<Object?>.broadcast();
  final subscriptions = <List<String>>[];
  @override
  Stream<Object?> get batches => _controller.stream;

  void emitA({required int ltpMinor}) {
    _controller.add({
      'sequence': 1,
      'timestamp': 1787460000000,
      'updates': [
        {
          'instrumentId': 'A',
          'symbol': 'A',
          'ltpMinor': ltpMinor,
          'previousLtpMinor': 10100,
          'previousCloseMinor': 10000,
          'changeMinor': ltpMinor - 10000,
          'changePercent': (ltpMinor - 10000) / 100,
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
