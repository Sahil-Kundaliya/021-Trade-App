import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class HeatMapSkeleton extends StatelessWidget {
  const HeatMapSkeleton({this.height, this.shimmer = true, super.key});

  final double? height;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final mapHeight = height ?? AppSizes.heatMapMinHeight;
    final grid = SizedBox(
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
        Expanded(flex: 5, child: _Cell()),
        SizedBox(width: AppBorders.thin),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(flex: 3, child: _Cell()),
              SizedBox(height: AppBorders.thin),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(child: _Cell()),
                    SizedBox(width: AppBorders.thin),
                    Expanded(child: _Cell()),
                  ],
                ),
              ),
              SizedBox(height: AppBorders.thin),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _Cell()),
                    SizedBox(width: AppBorders.thin),
                    Expanded(child: _Cell()),
                    SizedBox(width: AppBorders.thin),
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: shimmerColorOf(context),
      borderRadius: AppRadius.xsBorderRadius,
    ),
  );
}
