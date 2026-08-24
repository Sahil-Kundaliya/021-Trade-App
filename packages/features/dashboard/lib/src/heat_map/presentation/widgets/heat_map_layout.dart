import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/heat_map_fund.dart';
import '../../domain/entities/heat_map_layout.dart';
import '../../domain/layout/squarified_treemap.dart';
import 'heat_map_tile.dart';

class HeatMapTreemap extends StatefulWidget {
  const HeatMapTreemap({required this.funds, this.onTileTap, super.key});

  final List<HeatMapFund> funds;
  final ValueChanged<HeatMapFund>? onTileTap;

  @override
  State<HeatMapTreemap> createState() => _HeatMapTreemapState();
}

class _HeatMapTreemapState extends State<HeatMapTreemap> {
  Size? _size;
  List<HeatMapFund>? _funds;
  HeatMapLayout? _layout;
  Map<String, HeatMapFund> _fundsByKey = const {};

  HeatMapLayout _layoutFor(Size size) {
    final fundsUnchanged =
        identical(_funds, widget.funds) ||
        (_funds != null &&
            _sameWeights(_funds!, widget.funds) &&
            _size == size);
    if (fundsUnchanged && _layout != null && _size == size) {
      return _layout!;
    }
    _funds = widget.funds;
    _size = size;
    _fundsByKey = {for (final fund in widget.funds) fund.marketKey: fund};
    _layout = SquarifiedTreemap.layout(
      nodes: [
        for (final fund in widget.funds)
          HeatMapWeightedNode(
            marketKey: fund.marketKey,
            weight: fund.heatMapWeight,
          ),
      ],
      width: size.width,
      height: size.height,
      gap: AppBorders.thin,
    );
    return _layout!;
  }

  static bool _sameWeights(List<HeatMapFund> left, List<HeatMapFund> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index].marketKey != right[index].marketKey ||
          left[index].heatMapWeight != right[index].heatMapWeight) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.width <= 0 || size.height <= 0) {
          return const SizedBox.shrink();
        }
        final layout = _layoutFor(size);
        return Stack(
          children: [
            for (final cell in layout.cells)
              Positioned(
                left: cell.leftFactor * size.width,
                top: cell.topFactor * size.height,
                width: cell.widthFactor * size.width,
                height: cell.heightFactor * size.height,
                child: HeatMapTile(
                  key: ValueKey(cell.marketKey),
                  fund: _fundsByKey[cell.marketKey]!,
                  size: Size(
                    cell.widthFactor * size.width,
                    cell.heightFactor * size.height,
                  ),
                  onTap: widget.onTileTap == null
                      ? null
                      : () => widget.onTileTap!(_fundsByKey[cell.marketKey]!),
                ),
              ),
          ],
        );
      },
    );
  }
}
