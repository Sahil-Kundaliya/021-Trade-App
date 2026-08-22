import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../market/data/mock_market_indices.dart';
import '../../../market/domain/entities/market_index.dart';

class DashboardMarketIndices extends StatelessWidget {
  const DashboardMarketIndices({super.key});

  @override
  Widget build(BuildContext context) {
    final items = mockMarketIndices.map(_toViewData).toList(growable: false);

    return MarketIndicesStrip(items: items);
  }
}

MarketIndexViewData _toViewData(MarketIndex index) {
  return MarketIndexViewData(
    name: index.name,
    value: _formatNumber(index.value),
    change: _formatSigned(index.change),
    changePercent: '${_formatSigned(index.changePercent)}%',
    isPositive: index.changePercent >= 0,
  );
}

String _formatSigned(double value) {
  final sign = value >= 0 ? '+' : '-';
  return '$sign${_formatNumber(value.abs())}';
}

String _formatNumber(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts.first;
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$grouped.${parts.last}';
}
