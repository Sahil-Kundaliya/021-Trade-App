import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HeatMapSkeleton extends StatelessWidget {
  const HeatMapSkeleton({this.height, this.shimmer = true, super.key});

  final double? height;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final requestedHeight = height ?? AppSizes.heatMapMinHeight;
    final mapHeight = requestedHeight.isFinite && requestedHeight > 0
        ? requestedHeight
              .clamp(AppSizes.heatMapMinHeight, AppSizes.heatMapMaxHeight)
              .toDouble()
        : AppSizes.heatMapMinHeight;
    final grid = SizedBox(
      width: double.infinity,
      height: mapHeight,
      child: const _HeatMapSkeletonGrid(),
    );
    return shimmer ? AppShimmer(child: grid) : grid;
  }
}

class _HeatMapSkeletonGrid extends StatelessWidget {
  const _HeatMapSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(flex: 3, child: _Cell()),
              SizedBox(height: AppSpacing.xxs),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _Cell()),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(flex: 2, child: _Cell()),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xxs),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(flex: 2, child: _Cell()),
              SizedBox(height: AppSpacing.xxs),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(child: _Cell()),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(child: _Cell()),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _Cell()),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(child: _Cell()),
                    SizedBox(width: AppSpacing.xxs),
                    Expanded(child: _Cell()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell();

  @override
  Widget build(BuildContext context) => const SkeletonBox(
    width: double.infinity,
    height: double.infinity,
    borderRadius: AppRadius.xsBorderRadius,
  );
}
