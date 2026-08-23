import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class PortfolioSkeleton extends StatelessWidget {
  const PortfolioSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(width: 104),
              SizedBox(height: AppSpacing.sm),
              SkeletonLine(width: 180, height: 28),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 52)),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: SkeletonBox(height: 52)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(height: AppSizes.touchTarget),
        const SizedBox(height: AppSpacing.lg),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLine(width: 92, height: 18),
            SkeletonBox(width: 116, height: 36),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < 4; index++) ...[
          const _HoldingSkeleton(),
          if (index < 3) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    ),
  );
}

class _HoldingSkeleton extends StatelessWidget {
  const _HoldingSkeleton();

  @override
  Widget build(BuildContext context) => const AppCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(widthFactor: .4, height: 14),
              SizedBox(height: AppSpacing.sm),
              SkeletonLine(widthFactor: .72),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: .56),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLine(width: 76, height: 14),
              SizedBox(height: AppSpacing.sm),
              SkeletonLine(width: 88),
            ],
          ),
        ),
      ],
    ),
  );
}
