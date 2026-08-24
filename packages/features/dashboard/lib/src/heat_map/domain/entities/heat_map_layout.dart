import 'package:flutter/foundation.dart';

@immutable
final class HeatMapCellLayout {
  const HeatMapCellLayout({
    required this.marketKey,
    required this.leftFactor,
    required this.topFactor,
    required this.widthFactor,
    required this.heightFactor,
  });

  final String marketKey;
  final double leftFactor;
  final double topFactor;
  final double widthFactor;
  final double heightFactor;

  double get areaFactor => widthFactor * heightFactor;

  @override
  bool operator ==(Object other) =>
      other is HeatMapCellLayout &&
      other.marketKey == marketKey &&
      other.leftFactor == leftFactor &&
      other.topFactor == topFactor &&
      other.widthFactor == widthFactor &&
      other.heightFactor == heightFactor;

  @override
  int get hashCode =>
      Object.hash(marketKey, leftFactor, topFactor, widthFactor, heightFactor);
}

@immutable
final class HeatMapLayout {
  const HeatMapLayout({required this.cells});

  final List<HeatMapCellLayout> cells;

  @override
  bool operator ==(Object other) =>
      other is HeatMapLayout && listEquals(other.cells, cells);

  @override
  int get hashCode => Object.hashAll(cells);
}

@immutable
final class HeatMapWeightedNode {
  const HeatMapWeightedNode({required this.marketKey, required this.weight});

  final String marketKey;
  final double weight;
}
