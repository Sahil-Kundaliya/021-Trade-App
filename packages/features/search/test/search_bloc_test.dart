import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search/src/fund_search/domain/entities/searchable_fund.dart';
import 'package:search/src/fund_search/domain/repositories/search_repository.dart';
import 'package:search/src/fund_search/presentation/bloc/search_bloc.dart';
import 'package:search/src/fund_search/presentation/bloc/search_event.dart';
import 'package:search/src/fund_search/presentation/bloc/search_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepository repository;
  late _FakeLivePricePlatform platform;
  late SearchBloc bloc;

  setUp(() {
    repository = _FakeRepository(_funds);
    platform = _FakeLivePricePlatform();
    bloc = SearchBloc(repository, LivePriceStreamManager(platform));
  });

  tearDown(() async {
    await bloc.close();
    await platform.close();
  });

  test('loads once and initially exposes three deterministic funds', () async {
    bloc.add(const SearchStarted());
    await _settle();

    expect(repository.calls, 1);
    expect(bloc.state.status, SearchStatus.loaded);
    expect(bloc.state.isSearchActive, isFalse);
    expect(bloc.state.visibleFunds.map((fund) => fund.marketKey), [
      'RELIANCE_EQ:NSE',
      'RELIANCE_FUT:NSE',
      'RELIANCE_CE:NSE',
    ]);
    expect(platform.activeIds, {
      'RELIANCE_EQ:NSE',
      'RELIANCE_FUT:NSE',
      'RELIANCE_CE:NSE',
    });
  });

  test(
    'two characters retain trading funds and three activate search',
    () async {
      bloc.add(const SearchStarted());
      await _settle();

      bloc.add(const SearchQueryChanged(query: 'RE'));
      await _settle();
      expect(bloc.state.isSearchActive, isFalse);
      expect(bloc.state.visibleFunds, hasLength(3));

      bloc.add(const SearchQueryChanged(query: '  rel  '));
      await _settle();
      expect(bloc.state.isSearchActive, isTrue);
      expect(bloc.state.visibleFunds.map((fund) => fund.marketKey), [
        'RELIANCE_EQ:BSE',
        'RELIANCE_EQ:NSE',
        'RELIANCE_CE:NSE',
        'RELIANCE_FUT:NSE',
      ]);
      expect(repository.calls, 1);
    },
  );

  test(
    'company search is case insensitive and category filtering is typed',
    () async {
      bloc.add(const SearchStarted());
      await _settle();

      bloc.add(const SearchQueryChanged(query: 'TaTa'));
      await _settle();
      expect(
        bloc.state.visibleFunds.map((fund) => fund.symbol),
        contains('TCS'),
      );

      bloc.add(const SearchCategoryChanged(SearchCategory.future));
      await _settle();
      expect(
        bloc.state.visibleFunds.every(
          (fund) => fund.category == SearchCategory.future,
        ),
        isTrue,
      );
    },
  );

  test('category filters recommendations before a query is active', () async {
    bloc.add(const SearchStarted());
    await _settle();

    bloc.add(const SearchCategoryChanged(SearchCategory.options));
    await _settle();
    expect(bloc.state.visibleFunds, hasLength(2));
    expect(
      bloc.state.visibleFunds.every(
        (fund) => fund.category == SearchCategory.options,
      ),
      isTrue,
    );
    expect(platform.activeIds, {'RELIANCE_CE:NSE', 'TCS_PE:NSE'});
  });
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

final class _FakeRepository implements SearchRepository {
  _FakeRepository(this.funds);

  final List<SearchableFund> funds;
  int calls = 0;

  @override
  Future<List<SearchableFund>> getFunds() async {
    calls++;
    return funds;
  }
}

final class _FakeLivePricePlatform implements LivePricePlatformApi {
  final StreamController<Object?> _batches = StreamController.broadcast();
  final Set<String> activeIds = {};

  @override
  Stream<Object?> get batches => _batches.stream;

  @override
  Future<void> subscribe(Iterable<LiveInstrumentSeed> instruments) async {
    activeIds.addAll(instruments.map((seed) => seed.marketKey));
  }

  @override
  Future<void> unsubscribe(Iterable<String> instrumentIds) async {
    activeIds.removeAll(instrumentIds);
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  Future<void> close() => _batches.close();
}

SearchableFund _fund({
  required String id,
  required String symbol,
  required String company,
  required SearchCategory category,
  TradeExchange exchange = TradeExchange.nse,
}) => SearchableFund(
  id: id,
  symbol: symbol,
  companyName: company,
  category: category,
  instrumentType: category.name,
  exchange: exchange,
  ltp: 100,
  change: 1,
  changePercent: 1,
  previousClose: 99,
  tickSize: 0.05,
  tags: const [],
);

final _funds = <SearchableFund>[
  _fund(
    id: 'RELIANCE_EQ',
    symbol: 'RELIANCE',
    company: 'Reliance Industries',
    category: SearchCategory.equity,
  ),
  _fund(
    id: 'RELIANCE_EQ',
    symbol: 'RELIANCE',
    company: 'Reliance Industries',
    category: SearchCategory.equity,
    exchange: TradeExchange.bse,
  ),
  _fund(
    id: 'TCS_EQ',
    symbol: 'TCS',
    company: 'Tata Consultancy Services',
    category: SearchCategory.equity,
  ),
  _fund(
    id: 'RELIANCE_FUT',
    symbol: 'RELIANCE AUG FUT',
    company: 'Reliance Industries Future',
    category: SearchCategory.future,
  ),
  _fund(
    id: 'TCS_FUT',
    symbol: 'TCS AUG FUT',
    company: 'Tata Consultancy Services Future',
    category: SearchCategory.future,
  ),
  _fund(
    id: 'RELIANCE_CE',
    symbol: 'RELIANCE AUG CE',
    company: 'Reliance Industries Option',
    category: SearchCategory.options,
  ),
  _fund(
    id: 'TCS_PE',
    symbol: 'TCS AUG PE',
    company: 'Tata Consultancy Services Option',
    category: SearchCategory.options,
  ),
];
