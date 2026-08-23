import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/price_candle.dart';
import '../../bloc/fund_chart/fund_chart_bloc.dart';
import '../../bloc/fund_chart/fund_chart_state.dart';
import '../fund_format.dart';

class FundLiveChart extends StatelessWidget {
  const FundLiveChart({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FundChartBloc, FundChartState>(
        buildWhen: (previous, current) => previous.status != current.status,
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
          FundChartStatus.loaded => const _LiveChartBody(),
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

class _LiveChartBody extends StatefulWidget {
  const _LiveChartBody();

  @override
  State<_LiveChartBody> createState() => _LiveChartBodyState();
}

class _LiveChartBodyState extends State<_LiveChartBody> {
  final _paint = ValueNotifier<_ChartPaintFrame?>(null);
  final _ohlc = ValueNotifier<PriceCandle?>(null);
  final _followLive = ValueNotifier<bool>(true);

  StreamSubscription<FundChartState>? _subscription;
  late _CandlestickPainter _painter;
  bool _trackingLive = true;
  double _pan = 0;
  double _zoom = 1;
  int? _inspectedIndex;
  FundChartPeriod? _period;

  @override
  void initState() {
    super.initState();
    _painter = _CandlestickPainter(_paint);
    _subscription = context.read<FundChartBloc>().stream.listen((state) {
      if (!mounted) return;
      _publish(state);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _publish(context.read<FundChartBloc>().state, forceTheme: true);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _paint.dispose();
    _ohlc.dispose();
    _followLive.dispose();
    _painter.dispose();
    super.dispose();
  }

  void _publish(FundChartState state, {bool forceTheme = false}) {
    if (state.status != FundChartStatus.loaded) return;
    if (_period != null && _period != state.period) {
      _inspectedIndex = null;
      _trackingLive = true;
      _pan = 0;
      _zoom = 1;
    }
    _period = state.period;
    final colors = context.appColors;
    final private = PrivacyModeScope.of(context);
    final count = state.visibleCount;
    final inspected = _inspectedIndex;
    final ohlc =
        inspected != null && inspected >= 0 && inspected < count
        ? state.candleAt(inspected)
        : state.visibleActive;
    final frame = _ChartPaintFrame(
      historical: state.period.isIntraday
          ? state.minuteHistorical
          : state.dailyHistorical,
      historicalStart: state.period.isIntraday
          ? 0
          : math.max(
              0,
              state.dailyHistorical.length -
                  state.period.dailyHistoricalLookback,
            ),
      active: state.visibleActive,
      latestLtpMinor: state.latestLtpMinor,
      direction: state.lastTickDirection,
      followLive: _trackingLive,
      pan: _pan,
      zoom: _zoom,
      inspectedIndex: _inspectedIndex,
      private: private,
      isIntraday: state.period.isIntraday,
      up: colors.priceUp,
      down: colors.priceDown,
      grid: colors.chartGrid,
      axis: colors.chartAxis,
      lastPrice: state.lastTickDirection == LivePriceDirection.down
          ? colors.priceDown
          : state.lastTickDirection == LivePriceDirection.up
          ? colors.priceUp
          : colors.chartAxis,
      axisStyle: context.appTextStyles.financialCaption.copyWith(
        color: colors.chartAxis,
        fontSize: 10,
      ),
    );
    if (forceTheme || _paint.value == null || !_paint.value!.samePaint(frame)) {
      _paint.value = frame;
    }
    if (!identical(_ohlc.value, ohlc) && _ohlc.value != ohlc) {
      _ohlc.value = ohlc;
    }
    if (_followLive.value != _trackingLive) {
      _followLive.value = _trackingLive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('PRICE HISTORY', style: context.appTextStyles.sectionTitle),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: _followLive,
              builder: (context, followLive, _) {
                if (followLive) return const SizedBox.shrink();
                return AppButton(
                  label: 'Go Live',
                  onPressed: () {
                    _trackingLive = true;
                    _pan = 0;
                    _zoom = 1;
                    _publish(context.read<FundChartBloc>().state);
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        BlocSelector<FundChartBloc, FundChartState, FundChartPeriod>(
          selector: (state) => state.period,
          builder: (context, period) => Row(
            children: [
              for (final value in FundChartPeriod.values) ...[
                AppChip(
                  label: switch (value) {
                    FundChartPeriod.oneDay => '1D',
                    FundChartPeriod.oneMonth => '1M',
                    FundChartPeriod.threeMonths => '3M',
                  },
                  selected: period == value,
                  onSelected: (_) => context.read<FundChartBloc>().add(
                    FundChartPeriodChanged(value),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ValueListenableBuilder<PriceCandle?>(
          valueListenable: _ohlc,
          builder: (context, candle, _) => _OhlcHeader(
            candle: candle,
            private: PrivacyModeScope.of(context),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 236,
          width: double.infinity,
          child: GestureDetector(
            onTapUp: (details) => _inspect(
              details.localPosition.dx,
              context.size?.width ?? 1,
            ),
            onLongPressMoveUpdate: (details) => _inspect(
              details.localPosition.dx,
              context.size?.width ?? 1,
            ),
            onDoubleTap: () {
              _trackingLive = true;
              _pan = 0;
              _zoom = 1;
              _inspectedIndex = null;
              _publish(context.read<FundChartBloc>().state);
            },
            onScaleUpdate: (details) {
              _zoom = (_zoom * details.scale).clamp(1.0, 6.0);
              final dragged = details.focalPointDelta.dx.abs() >= 0.8;
              if (dragged) {
                _pan += details.focalPointDelta.dx;
                _trackingLive = false;
              }
              _publish(context.read<FundChartBloc>().state);
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _painter,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _inspect(double x, double width) {
    final frame = _paint.value;
    if (frame == null || frame.length == 0 || width <= 0) return;
    final visible = math.max(12, (frame.length / frame.zoom).round());
    final maxStart = math.max(0, frame.length - visible);
    final start = frame.followLive
        ? maxStart
        : (maxStart - frame.pan / 8).round().clamp(0, maxStart);
    final slot = width / visible;
    _inspectedIndex = (start + (x / slot).floor()).clamp(0, frame.length - 1);
    _publish(context.read<FundChartBloc>().state);
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

class _ChartPaintFrame {
  const _ChartPaintFrame({
    required this.historical,
    required this.historicalStart,
    required this.active,
    required this.latestLtpMinor,
    required this.direction,
    required this.followLive,
    required this.pan,
    required this.zoom,
    required this.inspectedIndex,
    required this.private,
    required this.isIntraday,
    required this.up,
    required this.down,
    required this.grid,
    required this.axis,
    required this.lastPrice,
    required this.axisStyle,
  });

  final List<PriceCandle> historical;
  final int historicalStart;
  final PriceCandle? active;
  final int? latestLtpMinor;
  final LivePriceDirection direction;
  final bool followLive;
  final double pan;
  final double zoom;
  final int? inspectedIndex;
  final bool private;
  final bool isIntraday;
  final Color up;
  final Color down;
  final Color grid;
  final Color axis;
  final Color lastPrice;
  final TextStyle axisStyle;

  int get historicalCount => math.max(0, historical.length - historicalStart);
  int get length => historicalCount + (active == null ? 0 : 1);

  PriceCandle at(int index) {
    if (index < historicalCount) return historical[historicalStart + index];
    return active!;
  }

  bool samePaint(_ChartPaintFrame other) =>
      identical(historical, other.historical) &&
      historicalStart == other.historicalStart &&
      active == other.active &&
      latestLtpMinor == other.latestLtpMinor &&
      direction == other.direction &&
      followLive == other.followLive &&
      pan == other.pan &&
      zoom == other.zoom &&
      inspectedIndex == other.inspectedIndex &&
      private == other.private &&
      isIntraday == other.isIntraday &&
      up == other.up &&
      down == other.down &&
      grid == other.grid &&
      axis == other.axis &&
      lastPrice == other.lastPrice;
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter(this._frames) : super(repaint: _frames);

  final ValueNotifier<_ChartPaintFrame?> _frames;
  final Paint _gridPaint = Paint()..strokeWidth = 1;
  final Paint _wickPaint = Paint()..strokeWidth = 1;
  final Paint _bodyPaint = Paint();
  final Paint _overlayPaint = Paint();
  final List<TextPainter> _yLabels = [];
  final List<TextPainter> _xLabels = [];
  TextPainter? _ltpLabel;

  void dispose() {
    for (final label in _yLabels) {
      label.dispose();
    }
    for (final label in _xLabels) {
      label.dispose();
    }
    _ltpLabel?.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final frame = _frames.value;
    if (frame == null || frame.length == 0) return;
    const right = 52.0;
    const bottom = 22.0;
    final plot = Rect.fromLTWH(
      0,
      8,
      size.width - right,
      size.height - bottom - 8,
    );
    if (plot.width <= 0 || plot.height <= 0) return;
    final visibleCount = math.max(12, (frame.length / frame.zoom).round());
    final maxStart = math.max(0, frame.length - visibleCount);
    final start = frame.followLive
        ? maxStart
        : (maxStart - frame.pan / 8).round().clamp(0, maxStart);
    final end = math.min(frame.length, start + visibleCount);
    var minP = frame.at(start).lowMinor;
    var maxP = frame.at(start).highMinor;
    for (var i = start; i < end; i++) {
      final candle = frame.at(i);
      minP = math.min(minP, candle.lowMinor);
      maxP = math.max(maxP, candle.highMinor);
    }
    final ltp = frame.latestLtpMinor;
    if (ltp != null) {
      minP = math.min(minP, ltp);
      maxP = math.max(maxP, ltp);
    }
    final range = math.max(1, maxP - minP).toDouble();
    _gridPaint.color = frame.grid;
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), _gridPaint);
      final price = (maxP - range * i / 4) / 100;
      _paintCachedLabel(
        canvas,
        _yLabels,
        i,
        frame.private ? '••••' : price.toStringAsFixed(2),
        Offset(plot.right + 6, y - 6),
        frame.axisStyle,
      );
    }
    final slot = plot.width / (end - start);
    for (var i = start; i < end; i++) {
      final candle = frame.at(i);
      final local = i - start;
      final x = plot.left + slot * local + slot / 2;
      final highY = plot.top + (maxP - candle.highMinor) / range * plot.height;
      final lowY = plot.top + (maxP - candle.lowMinor) / range * plot.height;
      final openY = plot.top + (maxP - candle.openMinor) / range * plot.height;
      final closeY = plot.top + (maxP - candle.closeMinor) / range * plot.height;
      final color = candle.isBullish ? frame.up : frame.down;
      _wickPaint.color = color;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), _wickPaint);
      final bodyTop = math.min(openY, closeY);
      final bodyHeight = math.max(1.0, (openY - closeY).abs());
      _bodyPaint.color = color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, bodyTop + bodyHeight / 2),
          width: math.max(3, slot * 0.62),
          height: bodyHeight,
        ),
        _bodyPaint,
      );
    }
    if (ltp != null) {
      final y = plot.top + (maxP - ltp) / range * plot.height;
      _overlayPaint.color = frame.lastPrice;
      var x = plot.left;
      while (x < plot.right) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 4, plot.right), y),
          _overlayPaint,
        );
        x += 8;
      }
      final label = frame.private ? '••••' : (ltp / 100).toStringAsFixed(2);
      _ltpLabel?.dispose();
      _ltpLabel = TextPainter(
        text: TextSpan(
          text: label,
          style: frame.axisStyle.copyWith(color: Colors.white),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(plot.right + 2, y - 8, _ltpLabel!.width + 8, 16),
        const Radius.circular(3),
      );
      canvas.drawRRect(box, _overlayPaint);
      _ltpLabel!.paint(canvas, Offset(plot.right + 6, y - 7));
    }
    final step = math.max(1, (end - start) ~/ 6);
    var xIndex = 0;
    for (var i = start; i < end; i += step) {
      final candle = frame.at(i);
      _paintCachedLabel(
        canvas,
        _xLabels,
        xIndex,
        frame.isIntraday
            ? FundFormat.time(candle.startedAt)
            : FundFormat.axisDate(candle.startedAt),
        Offset(plot.left + slot * (i - start), plot.bottom + 4),
        frame.axisStyle,
      );
      xIndex += 1;
    }
    final inspected = frame.inspectedIndex;
    if (inspected != null) {
      final local = inspected - start;
      if (local >= 0 && local < end - start) {
        final x = plot.left + slot * local + slot / 2;
        _overlayPaint.color = frame.axis;
        canvas.drawLine(
          Offset(x, plot.top),
          Offset(x, plot.bottom),
          _overlayPaint,
        );
      }
    }
  }

  void _paintCachedLabel(
    Canvas canvas,
    List<TextPainter> cache,
    int index,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    while (cache.length <= index) {
      cache.add(
        TextPainter(textDirection: ui.TextDirection.ltr),
      );
    }
    final painter = cache[index];
    final current = painter.text;
    if (current is! TextSpan || current.text != text || current.style != style) {
      painter.text = TextSpan(text: text, style: style);
      painter.layout();
    }
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
