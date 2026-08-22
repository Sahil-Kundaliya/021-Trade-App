enum HoldingsSort {
  pnlDescending,
  pnlAscending,
  symbolAscending,
  symbolDescending,
  currentValueDescending,
  currentValueAscending,
}

extension HoldingsSortLabel on HoldingsSort {
  String get label => switch (this) {
    HoldingsSort.pnlDescending || HoldingsSort.pnlAscending => 'P&L',
    HoldingsSort.symbolAscending || HoldingsSort.symbolDescending => 'Symbol',
    HoldingsSort.currentValueDescending ||
    HoldingsSort.currentValueAscending => 'Current Value',
  };

  bool get descending => switch (this) {
    HoldingsSort.pnlDescending ||
    HoldingsSort.symbolDescending ||
    HoldingsSort.currentValueDescending => true,
    _ => false,
  };
}
