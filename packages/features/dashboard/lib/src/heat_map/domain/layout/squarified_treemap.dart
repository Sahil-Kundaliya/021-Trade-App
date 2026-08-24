import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../entities/heat_map_layout.dart';

/// Deterministic squarified treemap. Geometry depends only on weights, order,
/// container size, and gap — never on live prices.
abstract final class SquarifiedTreemap {
  @visibleForTesting
  static int layoutCallCount = 0;

  @visibleForTesting
  static void resetLayoutCallCount() => layoutCallCount = 0;

  static HeatMapLayout layout({
    required List<HeatMapWeightedNode> nodes,
    required double width,
    required double height,
    double gap = 0,
  }) {
    layoutCallCount++;
    if (nodes.isEmpty || width <= 0 || height <= 0) {
      return const HeatMapLayout(cells: []);
    }

    final ordered = List<HeatMapWeightedNode>.of(nodes)
      ..sort((left, right) {
        final byWeight = right.weight.compareTo(left.weight);
        if (byWeight != 0) return byWeight;
        return left.marketKey.compareTo(right.marketKey);
      });

    final pixels = <_PixelCell>[];
    _squarify(ordered, 0, 0, width, height, pixels);

    return HeatMapLayout(
      cells: List<HeatMapCellLayout>.unmodifiable(
        pixels.map((cell) => cell.toFactors(width, height, gap)),
      ),
    );
  }

  static void _squarify(
    List<HeatMapWeightedNode> items,
    double x,
    double y,
    double width,
    double height,
    List<_PixelCell> out,
  ) {
    if (items.isEmpty || width <= 0 || height <= 0) return;
    if (items.length == 1) {
      out.add(_PixelCell(items.single.marketKey, x, y, width, height));
      return;
    }

    final totalWeight = items.fold<double>(0, (sum, item) => sum + item.weight);
    if (totalWeight <= 0) {
      out.add(_PixelCell(items.first.marketKey, x, y, width, height));
      return;
    }

    var count = 1;
    var bestWorst = double.infinity;
    var rowWeight = 0.0;
    for (var index = 0; index < items.length; index++) {
      rowWeight += items[index].weight;
      final worst = _worstAspect(
        items.sublist(0, index + 1),
        rowWeight,
        totalWeight,
        width,
        height,
      );
      if (worst <= bestWorst) {
        bestWorst = worst;
        count = index + 1;
      } else {
        rowWeight -= items[index].weight;
        break;
      }
    }

    final row = items.sublist(0, count);
    final rest = items.sublist(count);
    final rowTotal = row.fold<double>(0, (sum, item) => sum + item.weight);
    final fraction = rowTotal / totalWeight;

    if (width >= height) {
      final sliceWidth = width * fraction;
      var cursorY = y;
      for (final item in row) {
        final sliceHeight = height * (item.weight / rowTotal);
        out.add(
          _PixelCell(item.marketKey, x, cursorY, sliceWidth, sliceHeight),
        );
        cursorY += sliceHeight;
      }
      _squarify(rest, x + sliceWidth, y, width - sliceWidth, height, out);
      return;
    }

    final sliceHeight = height * fraction;
    var cursorX = x;
    for (final item in row) {
      final sliceWidth = width * (item.weight / rowTotal);
      out.add(_PixelCell(item.marketKey, cursorX, y, sliceWidth, sliceHeight));
      cursorX += sliceWidth;
    }
    _squarify(rest, x, y + sliceHeight, width, height - sliceHeight, out);
  }

  static double _worstAspect(
    List<HeatMapWeightedNode> row,
    double rowWeight,
    double totalWeight,
    double width,
    double height,
  ) {
    final containerArea = width * height;
    final rowArea = containerArea * (rowWeight / totalWeight);
    if (rowArea <= 0) return double.infinity;

    var worst = 1.0;
    if (width >= height) {
      final stripWidth = rowArea / height;
      for (final item in row) {
        final itemHeight =
            (containerArea * (item.weight / totalWeight)) / stripWidth;
        worst = math.max(worst, _aspect(stripWidth, itemHeight));
      }
    } else {
      final stripHeight = rowArea / width;
      for (final item in row) {
        final itemWidth =
            (containerArea * (item.weight / totalWeight)) / stripHeight;
        worst = math.max(worst, _aspect(itemWidth, stripHeight));
      }
    }
    return worst;
  }

  static double _aspect(double width, double height) {
    if (width <= 0 || height <= 0) return double.infinity;
    return width > height ? width / height : height / width;
  }
}

final class _PixelCell {
  const _PixelCell(this.marketKey, this.x, this.y, this.width, this.height);

  final String marketKey;
  final double x;
  final double y;
  final double width;
  final double height;

  HeatMapCellLayout toFactors(
    double containerWidth,
    double containerHeight,
    double gap,
  ) {
    final inset = gap / 2;
    final left = (x + inset).clamp(0, containerWidth);
    final top = (y + inset).clamp(0, containerHeight);
    final right = (x + width - inset).clamp(left, containerWidth);
    final bottom = (y + height - inset).clamp(top, containerHeight);
    return HeatMapCellLayout(
      marketKey: marketKey,
      leftFactor: left / containerWidth,
      topFactor: top / containerHeight,
      widthFactor: (right - left) / containerWidth,
      heightFactor: (bottom - top) / containerHeight,
    );
  }
}
