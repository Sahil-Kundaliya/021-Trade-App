import 'dart:math' as math;

import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/fund_details.dart';
import '../../../domain/entities/price_candle.dart';
import '../../bloc/fund_chart/fund_chart_bloc.dart';
import '../../bloc/fund_chart/fund_chart_state.dart';
import '../fund_format.dart';

class FundLiveChart extends StatelessWidget {
  const FundLiveChart({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FundChartBloc, FundChartState>(
        builder: (context, state) => switch (state.status) {
          FundChartStatus.initial || FundChartStatus.loading =>
            const FundChartSkeleton(),
          FundChartStatus.error => AppErrorState(
            title: 'Unable to load chart',
            description: state.errorMessage,
            onRetry: () => context.read<FundChartBloc>().add(
              const FundChartRetryRequested(),
            ),
            compact: true,
          ),
          FundChartStatus.loaded => _LoadedChart(state: state),
        },
      );
}

class FundChartSkeleton extends StatelessWidget {
  const FundChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLine(width: 72, height: 14),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: [
            SkeletonBox(width: 36, height: 28),
            SizedBox(width: AppSpacing.xs),
            SkeletonBox(width: 36, height: 28),
            SizedBox(width: AppSpacing.xs),
            SkeletonBox(width: 36, height: 28),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLine(widthFactor: .7, height: 12),
        const SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 220, borderRadius: AppRadius.mdBorderRadius),
      ],
    ),
  );
}

class _LoadedChart extends StatefulWidget {
  const _LoadedChart({required this.state});
  final FundChartState state;

  @override
  State<_LoadedChart> createState() => _LoadedChartState();
}

class _LoadedChartState extends State<_LoadedChart> {
  bool _followLive = true;
  double _pan = 0;
  double _zoom = 1;
  int? _inspectedIndex;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final private = PrivacyModeScope.of(context);
    final active = _inspectedCandle(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('CHART', style: context.appTextStyles.sectionTitle),
            const Spacer(),
            if (!_followLive)
              AppButton(
                label: 'Go Live',
                onPressed: () => setState(() {
                  _followLive = true;
                  _pan = 0;
                  _zoom = 1;
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final period in FundChartPeriod.values) ...[
              AppChip(
                label: switch (period) {
                  FundChartPeriod.oneDay => '1D',
                  FundChartPeriod.oneMonth => '1M',
                  FundChartPeriod.threeMonths => '3M',
                },
                selected: state.period == period,
                onSelected: (_) => context.read<FundChartBloc>().add(
                  FundChartPeriodChanged(period),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _OhlcHeader(candle: active, private: private),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 236,
          child: state.period == FundChartPeriod.oneDay
              ? (state.candles.isEmpty
                    ? Center(
                        child: Text(
                          'Chart data unavailable',
                          style: context.appTextStyles.bodySecondary,
                        ),
                      )
                    : _CandleInteractive(
                        candles: state.candles,
                        latestLtpMinor: state.latestLtpMinor,
                        direction: state.lastTickDirection,
                        followLive: _followLive,
                        pan: _pan,
                        zoom: _zoom,
                        inspectedIndex: _inspectedIndex,
                        private: private,
                        onInspect: (index) =>
                            setState(() => _inspectedIndex = index),
                        onPanZoom: (pan, zoom, follow) => setState(() {
                          _pan = pan;
                          _zoom = zoom;
                          _followLive = follow;
                        }),
                      ))
              : _HistoryLineChart(
                  points: state.selectedHistory,
                  private: private,
                ),
        ),
      ],
    );
  }

  PriceCandle? _inspectedCandle(FundChartState state) {
    final index = _inspectedIndex;
    if (index != null && index >= 0 && index < state.candles.length) {
      return state.candles[index];
    }
    return state.activeCandle;
  }
}

class _OhlcHeader extends StatelessWidget {
  const _OhlcHeader({required this.candle, required this.private});
  final PriceCandle? candle;
  final bool private;

  @override
  Widget build(BuildContext context) {
    if (candle == null) return const SizedBox.shrink();
    Widget cell(String label, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: context.appTextStyles.financialCaption),
        SensitiveValueText(
          value,
          type: SensitiveValueType.currency,
          maskedValue: '$label ${PrivacyMask.number}',
          style: context.appTextStyles.financialCaption,
        ),
      ],
    );
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        cell('O', private ? PrivacyMask.number : FundFormat.money(candle!.open)),
        cell('H', private ? PrivacyMask.number : FundFormat.money(candle!.high)),
        cell('L', private ? PrivacyMask.number : FundFormat.money(candle!.low)),
        cell('C', private ? PrivacyMask.number : FundFormat.money(candle!.close)),
      ],
    );
  }
}

class _CandleInteractive extends StatelessWidget {
  const _CandleInteractive({
    required this.candles,
    required this.latestLtpMinor,
    required this.direction,
    required this.followLive,
    required this.pan,
    required this.zoom,
    required this.inspectedIndex,
    required this.private,
    required this.onInspect,
    required this.onPanZoom,
  });

  final List<PriceCandle> candles;
  final int? latestLtpMinor;
  final LivePriceDirection direction;
  final bool followLive;
  final double pan;
  final double zoom;
  final int? inspectedIndex;
  final bool private;
  final ValueChanged<int?> onInspect;
  final void Function(double pan, double zoom, bool follow) onPanZoom;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTapUp: (details) => onInspect(
        _indexFor(details.localPosition.dx, context.size?.width ?? 1),
      ),
      onLongPressMoveUpdate: (details) => onInspect(
        _indexFor(details.localPosition.dx, context.size?.width ?? 1),
      ),
      onDoubleTap: () => onPanZoom(0, 1, true),
      onScaleUpdate: (details) {
        final nextZoom = (zoom * details.scale).clamp(1.0, 6.0);
        final nextPan = followLive && details.focalPointDelta.dx.abs() < 0.8
            ? pan
            : pan + details.focalPointDelta.dx;
        onPanZoom(nextPan, nextZoom, details.focalPointDelta.dx.abs() < 0.8);
      },
      child: CustomPaint(
        painter: _CandlestickPainter(
          candles: candles,
          latestLtpMinor: latestLtpMinor,
          up: colors.priceUp,
          down: colors.priceDown,
          grid: colors.chartGrid,
          axis: colors.chartAxis,
          lastPrice: direction == LivePriceDirection.down
              ? colors.priceDown
              : direction == LivePriceDirection.up
              ? colors.priceUp
              : colors.chartAxis,
          followLive: followLive,
          pan: pan,
          zoom: zoom,
          inspectedIndex: inspectedIndex,
          private: private,
          axisStyle: context.appTextStyles.financialCaption.copyWith(
            color: colors.chartAxis,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  int? _indexFor(double x, double width) {
    if (candles.isEmpty || width <= 0) return null;
    final visible = math.max(12, (candles.length / zoom).round());
    final start = followLive
        ? math.max(0, candles.length - visible)
        : (candles.length - visible - pan / 8).round().clamp(
            0,
            math.max(0, candles.length - visible),
          );
    final slot = width / visible;
    return (start + (x / slot).floor()).clamp(0, candles.length - 1).toInt();
  }
}

class _CandlestickPainter extends CustomPainter {
  const _CandlestickPainter({
    required this.candles,
    required this.latestLtpMinor,
    required this.up,
    required this.down,
    required this.grid,
    required this.axis,
    required this.lastPrice,
    required this.followLive,
    required this.pan,
    required this.zoom,
    required this.inspectedIndex,
    required this.private,
    required this.axisStyle,
  });

  final List<PriceCandle> candles;
  final int? latestLtpMinor;
  final Color up;
  final Color down;
  final Color grid;
  final Color axis;
  final Color lastPrice;
  final bool followLive;
  final double pan;
  final double zoom;
  final int? inspectedIndex;
  final bool private;
  final TextStyle axisStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    const right = 52.0;
    const bottom = 22.0;
    final plot = Rect.fromLTWH(0, 8, size.width - right, size.height - bottom - 8);
    final visibleCount = math.max(12, (candles.length / zoom).round());
    final maxStart = math.max(0, candles.length - visibleCount);
    final start = followLive
        ? maxStart
        : (maxStart - pan / 8).round().clamp(0, maxStart);
    final visible = candles.sublist(
      start,
      math.min(candles.length, start + visibleCount),
    );
    var minP = visible.first.lowMinor;
    var maxP = visible.first.highMinor;
    for (final candle in visible) {
      minP = math.min(minP, candle.lowMinor);
      maxP = math.max(maxP, candle.highMinor);
    }
    final ltp = latestLtpMinor;
    if (ltp != null) {
      minP = math.min(minP, ltp);
      maxP = math.max(maxP, ltp);
    }
    final range = math.max(1, maxP - minP).toDouble();
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final price = (maxP - range * i / 4) / 100;
      _label(
        canvas,
        private ? '••••' : price.toStringAsFixed(2),
        Offset(plot.right + 6, y - 6),
      );
    }
    final slot = plot.width / visible.length;
    for (var i = 0; i < visible.length; i++) {
      final candle = visible[i];
      final x = plot.left + slot * i + slot / 2;
      final highY = plot.top + (maxP - candle.highMinor) / range * plot.height;
      final lowY = plot.top + (maxP - candle.lowMinor) / range * plot.height;
      final openY = plot.top + (maxP - candle.openMinor) / range * plot.height;
      final closeY = plot.top + (maxP - candle.closeMinor) / range * plot.height;
      final color = candle.isBullish ? up : down;
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        Paint()
          ..color = color
          ..strokeWidth = 1,
      );
      final bodyTop = math.min(openY, closeY);
      final bodyHeight = math.max(1.0, (openY - closeY).abs());
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, bodyTop + bodyHeight / 2),
          width: math.max(3, slot * 0.62),
          height: bodyHeight,
        ),
        Paint()..color = color,
      );
    }
    if (ltp != null) {
      final y = plot.top + (maxP - ltp) / range * plot.height;
      final dash = Paint()
        ..color = lastPrice
        ..strokeWidth = 1;
      var x = plot.left;
      while (x < plot.right) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, plot.right), y), dash);
        x += 8;
      }
      final label = private ? '••••' : (ltp / 100).toStringAsFixed(2);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: axisStyle.copyWith(color: lastPrice),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(plot.right + 2, y - 8, tp.width + 8, 16),
        const Radius.circular(3),
      );
      canvas.drawRRect(box, Paint()..color = lastPrice);
      tp.paint(canvas, Offset(plot.right + 6, y - 7));
    }
    for (var i = 0; i < visible.length; i += math.max(1, visible.length ~/ 6)) {
      _label(
        canvas,
        FundFormat.time(visible[i].startedAt),
        Offset(plot.left + slot * i, plot.bottom + 4),
      );
    }
    if (inspectedIndex != null) {
      final local = inspectedIndex! - start;
      if (local >= 0 && local < visible.length) {
        final x = plot.left + slot * local + slot / 2;
        canvas.drawLine(
          Offset(x, plot.top),
          Offset(x, plot.bottom),
          Paint()
            ..color = axis
            ..strokeWidth = 1,
        );
      }
    }
  }

  void _label(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: axisStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.latestLtpMinor != latestLtpMinor ||
      oldDelegate.pan != pan ||
      oldDelegate.zoom != zoom ||
      oldDelegate.followLive != followLive ||
      oldDelegate.inspectedIndex != inspectedIndex ||
      oldDelegate.private != private ||
      oldDelegate.up != up ||
      oldDelegate.down != down;
}

class _HistoryLineChart extends StatelessWidget {
  const _HistoryLineChart({required this.points, required this.private});
  final List<FundHistoryPoint> points;
  final bool private;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Center(
        child: Text(
          'Chart data unavailable',
          style: context.appTextStyles.bodySecondary,
        ),
      );
    }
    return CustomPaint(
      painter: _HistoryPainter(
        points: points,
        line: context.appColors.priceUp,
        grid: context.appColors.chartGrid,
        axis: context.appColors.chartAxis,
        private: private,
        axisStyle: context.appTextStyles.financialCaption.copyWith(
          color: context.appColors.chartAxis,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _HistoryPainter extends CustomPainter {
  const _HistoryPainter({
    required this.points,
    required this.line,
    required this.grid,
    required this.axis,
    required this.private,
    required this.axisStyle,
  });

  final List<FundHistoryPoint> points;
  final Color line;
  final Color grid;
  final Color axis;
  final bool private;
  final TextStyle axisStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const right = 52.0;
    const bottom = 22.0;
    final plot = Rect.fromLTWH(0, 8, size.width - right, size.height - bottom - 8);
    final values = points.map((point) => point.value);
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = maxV - minV == 0 ? 1.0 : maxV - minV;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = plot.top + plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final price = maxV - range * i / 3;
      final tp = TextPainter(
        text: TextSpan(
          text: private ? '••••' : price.toStringAsFixed(2),
          style: axisStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.right + 6, y - 6));
    }
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = plot.left + plot.width * i / (points.length - 1);
      final y = plot.bottom - (points[i].value - minV) / range * plot.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HistoryPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.private != private;
}
