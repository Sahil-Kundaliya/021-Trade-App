import 'package:flutter/material.dart';

import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_durations.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.shimmer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = widget.enabled && !reducedMotion;
    if (_animate == shouldAnimate) return;
    _animate = shouldAnimate;
    if (_animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) return;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _animate = widget.enabled && !reducedMotion;
    if (_animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (!widget.enabled || !_animate) {
      return _ShimmerScope(color: colors.skeletonBase, child: widget.child);
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => _ShimmerScope(
        color: Color.lerp(
          colors.skeletonBase,
          colors.skeletonHighlight,
          _triangleWave(_controller.value),
        )!,
        child: child!,
      ),
    );
  }
}

double _triangleWave(double value) => 1 - ((value * 2) - 1).abs();

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.color, required super.child});

  final Color color;

  static Color colorOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.color ??
      context.appColors.skeletonBase;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) => color != oldWidget.color;
}

Color shimmerColorOf(BuildContext context) => _ShimmerScope.colorOf(context);
