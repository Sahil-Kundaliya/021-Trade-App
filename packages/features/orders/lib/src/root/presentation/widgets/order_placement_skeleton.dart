import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrderPlacementSkeleton extends StatelessWidget {
  const OrderPlacementSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(height: AppSizes.touchTarget),
              const SizedBox(height: AppSpacing.lg),
              const Row(
                children: [
                  Expanded(child: SkeletonBox(height: AppSizes.touchTarget)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: SkeletonBox(height: AppSizes.touchTarget)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < 5; index++) ...[
                const SkeletonLine(width: 84),
                const SizedBox(height: AppSpacing.xs),
                const SkeletonBox(height: AppSizes.touchTarget),
                const SizedBox(height: AppSpacing.md),
              ],
              const AppCard(
                child: Column(
                  children: [
                    SkeletonLine(widthFactor: .92),
                    SizedBox(height: AppSpacing.md),
                    SkeletonLine(widthFactor: .76),
                    SizedBox(height: AppSpacing.md),
                    SkeletonLine(widthFactor: .86),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SkeletonBox(height: AppSizes.buttonHeightLg),
            ],
          ),
        ),
      ),
    ),
  );
}
