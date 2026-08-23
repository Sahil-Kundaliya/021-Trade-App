import 'package:core_data/core_data.dart';

import '../entities/option_chain.dart';

class OptionChainLoadResult {
  const OptionChainLoadResult({
    required this.snapshot,
    required this.allContracts,
    this.underlying,
  });

  final OptionChainSnapshot snapshot;
  final List<OptionContract> allContracts;
  final FundDto? underlying;
}

abstract interface class OptionChainRepository {
  Future<OptionChainLoadResult> getOptionChain({
    required String underlyingSymbol,
    required TradeExchange exchange,
    DateTime? expiry,
    int? selectedStrikeMinor,
    int? spotMinor,
  });
}
