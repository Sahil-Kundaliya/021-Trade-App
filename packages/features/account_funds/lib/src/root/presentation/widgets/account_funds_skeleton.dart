import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class AccountFundsSkeleton extends StatelessWidget {
  const AccountFundsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(widthFactor: .32, height: 12),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLine(widthFactor: .48, height: 22),
          const SizedBox(height: AppSpacing.xxl),
          const SkeletonLine(widthFactor: .28, height: 12),
          const SizedBox(height: AppSpacing.lg),
          const Center(child: SkeletonLine(widthFactor: .55, height: 28)),
          const SizedBox(height: AppSpacing.sm),
          const Center(child: SkeletonLine(widthFactor: .4, height: 11)),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(child: SkeletonBox(height: AppSizes.controlCompact)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: AppSizes.controlCompact)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: AppSizes.controlCompact)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox(height: AppSizes.controlCompact)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SkeletonLine(widthFactor: .24, height: 12),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < 3; index++) ...[
            const SkeletonBox(height: AppSizes.touchTarget),
            if (index < 2) const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          const SkeletonBox(height: AppSizes.touchTarget),
          const SizedBox(height: AppSpacing.xxl),
          const SkeletonBox(height: AppSizes.buttonHeightMd),
        ],
      ),
    ),
  );
}
