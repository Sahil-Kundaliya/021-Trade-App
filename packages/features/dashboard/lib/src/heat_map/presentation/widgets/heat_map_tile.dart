import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../bloc/market_heat_map_bloc.dart';
import '../bloc/market_heat_map_state.dart';

enum HeatMapTileDensity { large, medium, small }

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
    if (size.width >= 108 && size.height >= 72) {
      return HeatMapTileDensity.large;
    }
    if (size.width >= 72 && size.height >= 52) {
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

    final private = PrivacyModeScope.of(context);
    final colors = context.appColors;
    final swatch = colors.heatMapSwatch(live.changePercent);
    final density = HeatMapTile.densityFor(size);
    final tooltip = _tooltip(private, live);

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
              padding: const EdgeInsets.all(AppSpacing.xs),
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
                    private: private,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(bool private, HeatMapTileLiveViewData live) {
    final ltp = private
        ? PrivacyMask.currency
        : FinancialFormatter.price(live.ltp);
    final change = private
        ? '${PrivacyMask.number} (${PrivacyMask.percentage})'
        : FinancialFormatter.changeGroup(live.change, live.changePercent);
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
    required this.private,
  });

  final String symbol;
  final HeatMapTileLiveViewData live;
  final Color onFill;
  final HeatMapTileDensity density;
  final bool private;

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
        if (density == HeatMapTileDensity.large) ...[
          const SizedBox(height: AppSpacing.xxs),
          SensitiveValueText(
            FinancialFormatter.price(live.ltp),
            type: SensitiveValueType.currency,
            isMasked: private,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.financialSmall.copyWith(color: onFill),
          ),
        ],
        if (density != HeatMapTileDensity.small) ...[
          const SizedBox(height: AppSpacing.xxs),
          _HeatMapChange(live: live, onFill: onFill, private: private),
        ],
      ],
    );
  }
}

class _HeatMapChange extends StatelessWidget {
  const _HeatMapChange({
    required this.live,
    required this.onFill,
    required this.private,
  });

  final HeatMapTileLiveViewData live;
  final Color onFill;
  final bool private;

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
            isMasked: private,
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
