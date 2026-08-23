import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class FundDetailsSkeleton extends StatelessWidget {
  const FundDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(widthFactor: .42, height: 22),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonLine(widthFactor: .7),
                  ],
                ),
              ),
              SkeletonCircle(size: AppSizes.touchTarget),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonLine(width: 156, height: 30),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              SkeletonBox(width: 62, height: 24),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(width: 74, height: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(child: SkeletonBox(height: AppSizes.buttonHeightLg)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonBox(height: AppSizes.buttonHeightLg)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final height in [156.0, 196.0, 180.0, 132.0, 132.0, 168.0]) ...[
            const SkeletonLine(widthFactor: .34, height: 18),
            const SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: height),
            const SizedBox(height: AppSpacing.xl),
          ],
        ],
      ),
    ),
  );
}
