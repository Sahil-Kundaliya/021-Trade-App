import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/option_chain.dart';
import '../../domain/repositories/option_chain_repository.dart';
import '../mappers/fund_chart_mapper.dart';

@LazySingleton(as: OptionChainRepository)
final class OptionChainRepositoryImpl implements OptionChainRepository {
  OptionChainRepositoryImpl(this._tradingLocalApi);

  final TradingLocalApi _tradingLocalApi;
  List<FundDto>? _universe;

  Future<List<FundDto>> _funds() async =>
      _universe ??= await _tradingLocalApi.getFunds();

  @override
  Future<OptionChainLoadResult> getOptionChain({
    required String underlyingSymbol,
    required TradeExchange exchange,
    DateTime? expiry,
    int? selectedStrikeMinor,
    int? spotMinor,
  }) async {
    final funds = await _funds();
    final contracts = <OptionContract>[];
    final futures = <FutureOverview>[];
    FundDto? underlying;
    for (final fund in funds) {
      if (fund.instrumentType == 'EQUITY' &&
          (fund.symbol == underlyingSymbol ||
              fund.underlyingSymbol == underlyingSymbol)) {
        underlying ??= fund;
      }
      final option = OptionChainMapper.contract(fund);
      if (option != null && option.underlyingSymbol == underlyingSymbol) {
        contracts.add(option);
      }
      final future = OptionChainMapper.future(fund);
      if (future != null &&
          (fund.underlyingSymbol == underlyingSymbol ||
              fund.symbol.startsWith(underlyingSymbol))) {
        futures.add(future);
      }
    }

    futures.sort((a, b) => a.expiry.compareTo(b.expiry));
    final expiries =
        contracts
            .map(
              (contract) => DateTime(
                contract.expiry.year,
                contract.expiry.month,
                contract.expiry.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();
    final selected = expiry ?? (expiries.isEmpty ? null : expiries.first);
    final rows = selected == null
        ? const <OptionChainRow>[]
        : OptionChainAssembler.rows(
            contracts: contracts,
            expiry: selected,
            spotMinor: spotMinor,
            selectedStrikeMinor: selectedStrikeMinor,
          );
    return OptionChainLoadResult(
      underlying: underlying,
      allContracts: contracts,
      snapshot: OptionChainSnapshot(
        underlyingSymbol: underlyingSymbol,
        availableExpiries: expiries,
        selectedExpiry: selected,
        rows: rows,
        contracts: [
          for (final contract in contracts)
            if (selected != null &&
                OptionChainAssembler.sameDay(contract.expiry, selected))
              contract,
        ],
        nearestFuture: futures.isEmpty ? null : futures.first,
        atmStrikeMinor: spotMinor == null
            ? null
            : OptionChainAssembler.atmStrikeMinor(
                strikes: rows.map((row) => row.strikeMinor),
                spotMinor: spotMinor,
              ),
      ),
    );
  }
}
