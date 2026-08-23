import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OrderBookSkeleton extends StatelessWidget {
  const OrderBookSkeleton({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var index = 0; index < 4; index++) ...[
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonLine(widthFactor: .48, height: 16),
                      ),
                      SkeletonBox(width: 72, height: 24),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonLine(widthFactor: .7),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: SkeletonLine(widthFactor: .64)),
                      Expanded(child: SkeletonLine(widthFactor: .54)),
                    ],
                  ),
                ],
              ),
            ),
            if (index < 3) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    ),
  );
}
