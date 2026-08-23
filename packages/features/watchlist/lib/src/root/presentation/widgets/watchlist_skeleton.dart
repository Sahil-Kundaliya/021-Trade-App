import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class WatchlistSkeleton extends StatelessWidget {
  const WatchlistSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppSizes.touchTarget,
          child: Row(
            children: const [
              SkeletonBox(width: 92, height: 34),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(width: 92, height: 34),
              Spacer(),
              SkeletonCircle(size: AppSizes.iconMd),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < 5; index++) ...[
          const _WatchlistRowSkeleton(),
          if (index < 4) const AppDivider(),
        ],
      ],
    ),
  );
}

class _WatchlistRowSkeleton extends StatelessWidget {
  const _WatchlistRowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(widthFactor: .34, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: .68, height: 10),
              SizedBox(height: AppSpacing.xs),
              SkeletonBox(width: 48, height: 18),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLine(width: 68, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(width: 92, height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}
