import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../bloc/market_heat_map_bloc.dart';
import '../bloc/market_heat_map_state.dart';

enum HeatMapTileDensity { large, medium, small }

extension HeatMapTileDensityPresentation on HeatMapTileDensity {
  bool get showsLtp => this != HeatMapTileDensity.small;
  bool get showsChange => this == HeatMapTileDensity.large;
}

class HeatMapTile extends StatelessWidget {
  const HeatMapTile({
    required this.fund,
    required this.size,
    this.onTap,
    super.key,
  });

  final HeatMapFund fund;
  final Size size;
  final VoidCallback? onTap;

  @visibleForTesting
  static final Map<String, int> debugBuildCounts = <String, int>{};

  @visibleForTesting
  static void resetDebugBuildCounts() => debugBuildCounts.clear();

  static HeatMapTileDensity densityFor(Size size) {
    if (size.width >= 96 && size.height >= 64) {
      return HeatMapTileDensity.large;
    }
    if (size.width >= 56 && size.height >= 36) {
      return HeatMapTileDensity.medium;
    }
    return HeatMapTileDensity.small;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      MarketHeatMapBloc,
      MarketHeatMapState,
      HeatMapTileLiveViewData
    >(
      selector: (state) => state.tileLiveDataFor(fund.marketKey),
      builder: (context, live) =>
          _HeatMapTileSurface(fund: fund, live: live, size: size, onTap: onTap),
    );
  }
}

class _HeatMapTileSurface extends StatelessWidget {
  const _HeatMapTileSurface({
    required this.fund,
    required this.live,
    required this.size,
    this.onTap,
  });

  final HeatMapFund fund;
  final HeatMapTileLiveViewData live;
  final Size size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    assert(() {
      HeatMapTile.debugBuildCounts.update(
        fund.marketKey,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      return true;
    }());

    final colors = context.appColors;
    final swatch = colors.heatMapSwatch(live.changePercent);
    final density = HeatMapTile.densityFor(size);
    final tooltip = _tooltip(live);

    return RepaintBoundary(
      child: _maybeTooltip(
        context: context,
        message: tooltip,
        child: Material(
          color: swatch.fill,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xsBorderRadius,
            side: BorderSide(
              color: colors.borderSubtle,
              width: AppBorders.thin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.xsBorderRadius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 2, 2),
              child: Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: _HeatMapTileBody(
                    symbol: fund.symbol,
                    live: live,
                    onFill: swatch.onFill,
                    density: density,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(HeatMapTileLiveViewData live) {
    final ltp = FinancialFormatter.price(live.ltp);
    final change = FinancialFormatter.changeGroup(
      live.change,
      live.changePercent,
    );
    return '${fund.symbol}\n'
        '${fund.companyName}\n'
        'LTP\n'
        '$ltp\n'
        'Change\n'
        '$change\n'
        'Weight\n'
        '${fund.heatMapWeight.toStringAsFixed(0)}';
  }
}

Widget _maybeTooltip({
  required BuildContext context,
  required String message,
  required Widget child,
}) {
  final desktop = switch (Theme.of(context).platform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };
  if (!desktop) return child;
  return Tooltip(
    message: message,
    waitDuration: const Duration(milliseconds: 400),
    child: child,
  );
}

class _HeatMapTileBody extends StatelessWidget {
  const _HeatMapTileBody({
    required this.symbol,
    required this.live,
    required this.onFill,
    required this.density,
  });

  final String symbol;
  final HeatMapTileLiveViewData live;
  final Color onFill;
  final HeatMapTileDensity density;

  @override
  Widget build(BuildContext context) {
    final styles = context.appTextStyles;
    final symbolStyle =
        (density == HeatMapTileDensity.large
                ? styles.marketSymbol
                : styles.label)
            .copyWith(color: onFill);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          symbol,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: symbolStyle,
        ),
        if (density.showsLtp) ...[
          const SizedBox(height: AppSpacing.xxs),
          LiveValueFlash(
            direction: live.liveDirection,
            updateId: live.liveUpdateId,
            normalColor: onFill,
            builder: (color) => SensitiveValueText(
              FinancialFormatter.price(live.ltp),
              type: SensitiveValueType.currency,
              isMasked: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.financialSmall.copyWith(color: color),
            ),
          ),
        ],
        if (density.showsChange) ...[
          const SizedBox(height: AppSpacing.xxs),
          _HeatMapChange(live: live, onFill: onFill),
        ],
      ],
    );
  }
}

class _HeatMapChange extends StatelessWidget {
  const _HeatMapChange({required this.live, required this.onFill});

  final HeatMapTileLiveViewData live;
  final Color onFill;

  @override
  Widget build(BuildContext context) {
    final sign = live.displaySign;
    final style = context.appTextStyles.financialCaption.copyWith(
      color: onFill,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SensitiveValueText(
            FinancialFormatter.percentage(live.changePercent),
            type: SensitiveValueType.percentage,
            isMasked: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (sign != 0) ...[
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            sign > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            size: AppSizes.iconTiny,
            color: onFill,
          ),
        ],
      ],
    );
  }
}
