import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../market/presentation/bloc/market_bloc.dart';
import '../../../market/presentation/bloc/market_state.dart';
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
    return BlocListener<MarketBloc, MarketState>(
      listenWhen: (previous, current) =>
          previous.selectedExchange != current.selectedExchange,
      listener: (context, state) {
        context.read<MarketHeatMapBloc>().add(
          MarketHeatMapExchangeChanged(state.selectedExchange),
        );
      },
      child: BlocBuilder<MarketHeatMapBloc, MarketHeatMapState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.exchange != current.exchange ||
            !identical(previous.funds, current.funds) ||
            previous.errorMessage != current.errorMessage,
        builder: (context, state) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: 'MARKET HEAT MAP',
                subtitle: 'Size by Amount · Color by Change %',
                level: AppSectionHeaderLevel.section,
                trailing: Text(
                  'Equity · ${state.exchange.code}',
                  style: context.appTextStyles.label.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              switch (state.status) {
                MarketHeatMapStatus.initial ||
                MarketHeatMapStatus.loading => const HeatMapSkeleton(),
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
        ),
      ),
    );
  }
}

class _HeatMapBody extends StatelessWidget {
  const _HeatMapBody({required this.funds, this.onTileTap});

  final List<HeatMapFund> funds;
  final ValueChanged<HeatMapFund>? onTileTap;

  static const double _maxWidth = 960;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(0, _maxWidth).toDouble();
            final height = (width * 0.68).clamp(
              AppSizes.heatMapMinHeight,
              AppSizes.heatMapMaxHeight,
            );
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
