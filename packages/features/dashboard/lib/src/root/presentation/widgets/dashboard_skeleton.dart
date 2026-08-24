import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../../heat_map/presentation/widgets/heat_map_skeleton.dart';

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
        const AppCard(child: _PortfolioSummarySkeleton()),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(height: 156),
        const SizedBox(height: AppSpacing.lg),
        const AppCard(child: HeatMapSkeleton(shimmer: false)),
        const SizedBox(height: AppSpacing.lg),
        const AppCard(child: _MarketScreenerSkeleton()),
        const SizedBox(height: AppSpacing.lg),
        const AppCard(child: _NewsSkeleton()),
      ],
    ),
  );
}

class _PortfolioSummarySkeleton extends StatelessWidget {
  const _PortfolioSummarySkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonLine(width: 132, height: 18),
      SizedBox(height: AppSpacing.lg),
      SkeletonLine(width: 96),
      SizedBox(height: AppSpacing.sm),
      SkeletonLine(width: 190, height: 28),
      SizedBox(height: AppSpacing.lg),
      AppDivider(),
      SizedBox(height: AppSpacing.md),
      SkeletonLine(width: 88),
      SizedBox(height: AppSpacing.xs),
      SkeletonLine(width: 140, height: 18),
    ],
  );
}

class _NewsSkeleton extends StatelessWidget {
  const _NewsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonLine(width: 132, height: 18),
      SizedBox(height: AppSpacing.lg),
      for (var index = 0; index < 4; index++) ...[
        const _NewsRowSkeleton(),
        if (index < 3) const AppDivider(),
      ],
    ],
  );
}

class _NewsRowSkeleton extends StatelessWidget {
  const _NewsRowSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: AppSizes.touchTarget, height: AppSizes.touchTarget),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(width: 120, height: 10),
              SizedBox(height: AppSpacing.sm),
              SkeletonLine(widthFactor: .8, height: 14),
              SizedBox(height: AppSpacing.sm),
              SkeletonLine(widthFactor: .95),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: .7),
            ],
          ),
        ),
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
