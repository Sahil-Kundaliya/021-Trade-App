import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../bloc/market_heat_map_bloc.dart';
import '../bloc/market_heat_map_event.dart';
import '../bloc/market_heat_map_state.dart';
import 'heat_map_layout.dart';
import 'heat_map_legend.dart';
import 'heat_map_skeleton.dart';

class DashboardHeatMap extends StatelessWidget {
  const DashboardHeatMap({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketHeatMapBloc, MarketHeatMapState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.exchange != current.exchange ||
          !identical(previous.funds, current.funds) ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: 'MARKET HEAT MAP',
                subtitle: 'Size by Amount · Color by Change %',
                level: AppSectionHeaderLevel.section,
                trailing: _ExchangeSwitch(
                  selected: state.exchange,
                  onSelected: (exchange) => context
                      .read<MarketHeatMapBloc>()
                      .add(MarketHeatMapExchangeChanged(exchange)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              switch (state.status) {
                MarketHeatMapStatus.initial ||
                MarketHeatMapStatus.loading => const _HeatMapLoading(),
                MarketHeatMapStatus.error => _HeatMapError(
                  onRetry: () => context.read<MarketHeatMapBloc>().add(
                    const MarketHeatMapRetryRequested(),
                  ),
                ),
                MarketHeatMapStatus.empty => const AppEmptyState(
                  title: 'No equity funds available',
                ),
                MarketHeatMapStatus.loaded => _HeatMapBody(
                  funds: state.funds,
                  onTileTap: (fund) => navigator?.openFund(
                    fundId: fund.fundId,
                    exchange: fund.exchange,
                  ),
                ),
              },
            ],
          ),
        );
      },
    );
  }
}

class _HeatMapLoading extends StatelessWidget {
  const _HeatMapLoading();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth
          .clamp(0, _HeatMapBody.maxWidth)
          .toDouble();
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: width,
          child: HeatMapSkeleton(
            key: const Key('heat-map-loading-skeleton'),
            height: _heatMapHeight(width),
          ),
        ),
      );
    },
  );
}

class _ExchangeSwitch extends StatelessWidget {
  const _ExchangeSwitch({required this.selected, required this.onSelected});

  final TradeExchange selected;
  final ValueChanged<TradeExchange> onSelected;

  @override
  Widget build(BuildContext context) => SegmentedButton<TradeExchange>(
    key: const Key('heat-map-exchange-switch'),
    showSelectedIcon: false,
    segments: [
      for (final exchange in TradeExchange.values)
        ButtonSegment<TradeExchange>(
          value: exchange,
          label: Text(
            exchange.code,
            key: Key('heat-map-exchange-${exchange.code.toLowerCase()}'),
          ),
        ),
    ],
    selected: {selected},
    onSelectionChanged: (selection) => onSelected(selection.single),
    style: ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(context.appTextStyles.label),
    ),
  );
}

class _HeatMapBody extends StatelessWidget {
  const _HeatMapBody({required this.funds, this.onTileTap});

  final List<HeatMapFund> funds;
  final ValueChanged<HeatMapFund>? onTileTap;

  static const double maxWidth = 960;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(0, maxWidth).toDouble();
            final height = _heatMapHeight(width);
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: width,
                height: height,
                child: HeatMapTreemap(funds: funds, onTileTap: onTileTap),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const HeatMapLegend(),
      ],
    );
  }
}

double _heatMapHeight(double width) => (width * 0.68)
    .clamp(AppSizes.heatMapMinHeight, AppSizes.heatMapMaxHeight)
    .toDouble();

class _HeatMapError extends StatelessWidget {
  const _HeatMapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppErrorState(
    title: 'Unable to load heat map',
    compact: true,
    onRetry: onRetry,
  );
}
