import 'package:flutter/material.dart';

import '../../privacy/privacy_mode_scope.dart';
import '../../theme/extensions/theme_context_extension.dart';
import '../../theme/tokens/app_durations.dart';

enum LiveValueDirection { up, down, flat }

typedef LiveValueColorBuilder = Widget Function(Color color);

/// A short text-color pulse for an already-updated live value.
///
/// [updateId] must identify a genuine live tick. The initial value never
/// pulses, and ordinary parent rebuilds do not replay the last animation.
class LiveValueFlash extends StatefulWidget {
  const LiveValueFlash({
    required this.direction,
    required this.updateId,
    required this.normalColor,
    required this.builder,
    this.padding = const EdgeInsets.symmetric(horizontal: 2),
    super.key,
  });

  final LiveValueDirection direction;
  final int? updateId;
  final Color normalColor;
  final LiveValueColorBuilder builder;
  final EdgeInsetsGeometry padding;

  @override
  State<LiveValueFlash> createState() => _LiveValueFlashState();
}

class _LiveValueFlashState extends State<LiveValueFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.liveValuePulse,
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotionCurves.livePrice,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeOf(context)?.disableAnimations == true ||
        PrivacyModeScope.of(context)) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant LiveValueFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.updateId == null || widget.updateId == oldWidget.updateId) {
      return;
    }
    if (widget.direction == LiveValueDirection.flat ||
        MediaQuery.maybeOf(context)?.disableAnimations == true ||
        PrivacyModeScope.of(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _fade,
        builder: (context, _) {
          final pulseColor = switch (widget.direction) {
            LiveValueDirection.up => context.appColors.priceUp,
            LiveValueDirection.down => context.appColors.priceDown,
            LiveValueDirection.flat => widget.normalColor,
          };
          return Padding(
            padding: widget.padding,
            child: widget.builder(
              Color.lerp(pulseColor, widget.normalColor, _fade.value)!,
            ),
          );
        },
      ),
    );
  }
}
