import 'package:flutter/material.dart';

import '../../theme/tokens/app_radius.dart';
import 'skeleton_box.dart';

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    this.width,
    this.widthFactor,
    this.height = 12,
    super.key,
  }) : assert(width == null || widthFactor == null);

  final double? width;
  final double? widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final line = SkeletonBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: AppRadius.pillBorderRadius,
    );
    if (widthFactor == null) return line;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: line,
    );
  }
}
