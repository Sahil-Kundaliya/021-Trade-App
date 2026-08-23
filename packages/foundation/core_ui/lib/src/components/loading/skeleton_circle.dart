import 'package:flutter/material.dart';

import 'app_shimmer.dart';

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: shimmerColorOf(context),
        shape: BoxShape.circle,
      ),
    ),
  );
}
