import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import 'holdings_sort.dart';

enum HoldingsStatus { initial, loading, loaded, empty, error }

class HoldingsState {
  const HoldingsState({
    this.status = HoldingsStatus.initial,
    this.holdings = const [],
    this.summary,
    this.sort = HoldingsSort.pnlDescending,
    this.errorMessage,
  });

  final HoldingsStatus status;
  final List<Holding> holdings;
  final PortfolioSummary? summary;
  final HoldingsSort sort;
  final String? errorMessage;

  HoldingsState copyWith({
    HoldingsStatus? status,
    List<Holding>? holdings,
    PortfolioSummary? summary,
    HoldingsSort? sort,
    String? errorMessage,
    bool clearError = false,
  }) => HoldingsState(
    status: status ?? this.status,
    holdings: holdings ?? this.holdings,
    summary: summary ?? this.summary,
    sort: sort ?? this.sort,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
