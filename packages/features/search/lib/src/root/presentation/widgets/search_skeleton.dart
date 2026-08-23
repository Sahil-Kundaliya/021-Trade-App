import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SkeletonBox(width: 86, height: 32),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonLine(width: 118, height: 14),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < 3; index++) ...[
            const _SearchResultSkeleton(),
            if (index < 2) const AppDivider(),
          ],
        ],
      ),
    ),
  );
}

class _SearchResultSkeleton extends StatelessWidget {
  const _SearchResultSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        SkeletonCircle(size: 40),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(widthFactor: .38, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: .72),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 84,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLine(width: 68, height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonLine(width: 84),
            ],
          ),
        ),
      ],
    ),
  );
}
