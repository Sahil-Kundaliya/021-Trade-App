import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/heat_map_fund.dart';

enum MarketHeatMapStatus { initial, loading, loaded, empty, error }

@immutable
final class HeatMapTileLiveViewData {
  const HeatMapTileLiveViewData({
    required this.ltp,
    required this.change,
    required this.changePercent,
  });

  final double ltp;
  final double change;
  final double changePercent;

  int get displaySign => FinancialFormatter.displaySign(change, changePercent);

  @override
  bool operator ==(Object other) =>
      other is HeatMapTileLiveViewData &&
      other.ltp == ltp &&
      other.change == change &&
      other.changePercent == changePercent;

  @override
  int get hashCode => Object.hash(ltp, change, changePercent);
}

class MarketHeatMapState {
  const MarketHeatMapState({
    this.status = MarketHeatMapStatus.initial,
    this.funds = const [],
    this.fundsByKey = const {},
    this.livePrices = const {},
    this.exchange = TradeExchange.nse,
    this.errorMessage,
  });

  final MarketHeatMapStatus status;
  final List<HeatMapFund> funds;
  final Map<String, HeatMapFund> fundsByKey;
  final Map<String, LivePriceTick> livePrices;
  final TradeExchange exchange;
  final String? errorMessage;

  HeatMapTileLiveViewData tileLiveDataFor(String marketKey) {
    final fund = fundsByKey[marketKey];
    final tick = livePrices[marketKey];
    final previousClose = fund?.previousClose ?? tick?.previousClose ?? 0;
    final ltp = tick?.ltp ?? fund?.initialLtp ?? 0;
    final change = previousClose == 0 ? 0.0 : ltp - previousClose;
    final changePercent = previousClose == 0
        ? 0.0
        : change / previousClose * 100;
    return HeatMapTileLiveViewData(
      ltp: FinancialFormatter.normalize(ltp),
      change: FinancialFormatter.normalize(change),
      changePercent: FinancialFormatter.normalize(changePercent),
    );
  }

  MarketHeatMapState copyWith({
    MarketHeatMapStatus? status,
    List<HeatMapFund>? funds,
    Map<String, HeatMapFund>? fundsByKey,
    Map<String, LivePriceTick>? livePrices,
    TradeExchange? exchange,
    String? errorMessage,
    bool clearError = false,
  }) => MarketHeatMapState(
    status: status ?? this.status,
    funds: funds ?? this.funds,
    fundsByKey: fundsByKey ?? this.fundsByKey,
    livePrices: livePrices ?? this.livePrices,
    exchange: exchange ?? this.exchange,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
