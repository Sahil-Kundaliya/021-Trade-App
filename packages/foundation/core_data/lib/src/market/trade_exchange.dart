enum TradeExchange {
  nse,
  bse;

  String get code => name.toUpperCase();

  static TradeExchange parse(String value) => switch (value.toUpperCase()) {
    'NSE' => TradeExchange.nse,
    'BSE' => TradeExchange.bse,
    _ => throw FormatException('Unsupported trade exchange: $value.'),
  };
}
