import 'package:flutter/material.dart';

import '../../theme/tokens/app_radius.dart';
import 'app_shimmer.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.height,
    this.width = double.infinity,
    this.borderRadius,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: shimmerColorOf(context),
        borderRadius: borderRadius ?? AppRadius.smBorderRadius,
      ),
    ),
  );
}
