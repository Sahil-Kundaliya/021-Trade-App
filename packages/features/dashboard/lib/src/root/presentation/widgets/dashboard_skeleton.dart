import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SkeletonLine(width: 132, height: 24),
            SkeletonBox(
              width: AppSizes.touchTarget,
              height: AppSizes.touchTarget,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _IndexStripSkeleton(),
        const SizedBox(height: AppSpacing.lg),
        const AppCard(child: _MarketScreenerSkeleton()),
      ],
    ),
  );
}

class _IndexStripSkeleton extends StatelessWidget {
  const _IndexStripSkeleton();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 76,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (_, _) => const SkeletonBox(width: 148, height: 76),
    ),
  );
}

class _MarketScreenerSkeleton extends StatelessWidget {
  const _MarketScreenerSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SkeletonLine(widthFactor: .42, height: 18),
      const SizedBox(height: AppSpacing.sm),
      const SkeletonLine(widthFactor: .3),
      const SizedBox(height: AppSpacing.lg),
      Row(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: SkeletonBox(width: 82, height: 32),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      const SkeletonLine(width: 72),
      const SizedBox(height: AppSpacing.xs),
      const SkeletonBox(height: AppSizes.touchTarget),
      const SizedBox(height: AppSpacing.md),
      const SkeletonBox(height: AppSizes.touchTarget),
      const SizedBox(height: AppSpacing.sm),
      for (var index = 0; index < 5; index++) ...[
        const _FundRowSkeleton(),
        if (index < 4) const AppDivider(),
      ],
    ],
  );
}

class _FundRowSkeleton extends StatelessWidget {
  const _FundRowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(widthFactor: .42, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: .7, height: 10),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLine(width: 72, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(width: 92, height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}
