import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';

class WatchlistMarketIndices extends StatelessWidget {
  const WatchlistMarketIndices({super.key});

  static const _items = <MarketIndexViewData>[
    MarketIndexViewData(
      name: 'NIFTY 50',
      value: '24,572.30',
      change: '+102.45',
      changePercent: '+0.42%',
      isPositive: true,
    ),
    MarketIndexViewData(
      name: 'BANK NIFTY',
      value: '51,820.45',
      change: '-93.20',
      changePercent: '-0.18%',
      isPositive: false,
    ),
    MarketIndexViewData(
      name: 'SENSEX',
      value: '80,940.20',
      change: '+249.60',
      changePercent: '+0.31%',
      isPositive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const MarketIndicesStrip(items: _items);
  }
}
