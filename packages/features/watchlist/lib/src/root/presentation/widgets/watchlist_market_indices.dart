import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class WatchlistMarketIndices extends StatefulWidget {
  const WatchlistMarketIndices({super.key});

  @override
  State<WatchlistMarketIndices> createState() => _WatchlistMarketIndicesState();
}

class _WatchlistMarketIndicesState extends State<WatchlistMarketIndices> {
  final Map<String, ValueNotifier<LivePriceTick?>> _ticks = {};
  List<MarketIndexDto> _indices = const [];
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _subscription;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      final indices = await GetIt.instance<TradingLocalApi>()
          .getMarketIndices();
      if (!mounted) return;
      final manager = GetIt.instance<LivePriceStreamManager>();
      for (final index in indices) {
        _ticks[index.id] = ValueNotifier(manager.latestFor(index.id));
      }
      setState(() => _indices = indices);
      final lease = manager.acquire(instruments: indices.map(_seed));
      _lease = lease;
      _subscription = lease.stream.listen(_onBatch);
    } on Object {
      // Keep the last static/live values when the platform feed is unavailable.
    }
  }

  void _onBatch(LivePriceBatch batch) {
    if (!mounted) return;
    for (final tick in batch.updates) {
      final notifier = _ticks[tick.instrumentId];
      if (notifier == null || notifier.value == tick) continue;
      notifier.value = tick;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_lease?.dispose());
    for (final notifier in _ticks.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MarketIndicesStrip.builder(
    itemCount: _indices.length,
    itemBuilder: (context, index) {
      final marketIndex = _indices[index];
      return ValueListenableBuilder<LivePriceTick?>(
        valueListenable: _ticks[marketIndex.id]!,
        builder: (_, tick, _) =>
            MarketIndexChip(item: _view(marketIndex, tick)),
      );
    },
  );
}

LiveInstrumentSeed _seed(MarketIndexDto index) => LiveInstrumentSeed.fromPrices(
  marketKey: index.id,
  fundId: index.id,
  exchange: index.exchange,
  assetType: LiveMarketAssetType.marketIndex,
  symbol: index.symbol,
  ltp: index.ltp,
  previousClose: index.previousClose,
  tickSize: index.tickSize,
);

MarketIndexViewData _view(MarketIndexDto index, LivePriceTick? tick) {
  final value = tick?.ltp ?? index.ltp;
  final change = value - index.previousClose;
  final percent = index.previousClose == 0
      ? 0.0
      : change / index.previousClose * 100;
  return MarketIndexViewData(
    id: index.id,
    name: index.symbol,
    ltp: value,
    change: change,
    changePercent: percent,
    liveDirection: _liveDirection(tick),
    liveUpdateId: tick?.sequence,
  );
}

LiveValueDirection _liveDirection(LivePriceTick? tick) =>
    switch (tick?.direction) {
      LivePriceDirection.up => LiveValueDirection.up,
      LivePriceDirection.down => LiveValueDirection.down,
      LivePriceDirection.flat || null => LiveValueDirection.flat,
    };
