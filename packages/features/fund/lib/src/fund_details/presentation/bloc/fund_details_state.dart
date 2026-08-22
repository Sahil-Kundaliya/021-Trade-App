import '../../domain/entities/available_watchlist.dart';
import '../../domain/entities/fund_details.dart';
import 'fund_details_event.dart';

enum FundDetailsStatus { initial, loading, loaded, error }

class FundHistorySummary {
  const FundHistorySummary({
    required this.start,
    required this.latest,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
  });
  final double start;
  final double latest;
  final double change;
  final double changePercent;
  final double high;
  final double low;
}

class FundDetailsState {
  const FundDetailsState({
    this.status = FundDetailsStatus.initial,
    this.fundId,
    this.fund,
    this.availableWatchlists = const [],
    this.selectedWatchlistId,
    this.selectedHistoryPeriod = FundHistoryPeriod.oneMonth,
    this.isAddingToWatchlist = false,
    this.isWatchlistPickerOpen = false,
    this.message,
    this.messageVersion = 0,
    this.errorMessage,
  });

  final FundDetailsStatus status;
  final String? fundId;
  final FundDetails? fund;
  final List<AvailableWatchlist> availableWatchlists;
  final String? selectedWatchlistId;
  final FundHistoryPeriod selectedHistoryPeriod;
  final bool isAddingToWatchlist;
  final bool isWatchlistPickerOpen;
  final String? message;
  final int messageVersion;
  final String? errorMessage;

  List<FundHistoryPoint> get selectedHistoryPoints {
    final details = fund;
    if (details == null) return const [];
    return selectedHistoryPeriod == FundHistoryPeriod.oneMonth
        ? details.priceHistory.oneMonth
        : details.priceHistory.threeMonths;
  }

  FundHistorySummary? get historySummary {
    final points = selectedHistoryPoints;
    if (points.isEmpty) return null;
    final start = points.first.value;
    final latest = points.last.value;
    final values = points.map((point) => point.value);
    final change = latest - start;
    return FundHistorySummary(
      start: start,
      latest: latest,
      change: change,
      changePercent: start == 0 ? 0 : change / start * 100,
      high: values.reduce((a, b) => a > b ? a : b),
      low: values.reduce((a, b) => a < b ? a : b),
    );
  }

  FundDetailsState copyWith({
    FundDetailsStatus? status,
    String? fundId,
    FundDetails? fund,
    List<AvailableWatchlist>? availableWatchlists,
    String? selectedWatchlistId,
    bool clearSelectedWatchlist = false,
    FundHistoryPeriod? selectedHistoryPeriod,
    bool? isAddingToWatchlist,
    bool? isWatchlistPickerOpen,
    String? message,
    bool clearMessage = false,
    int? messageVersion,
    String? errorMessage,
    bool clearError = false,
  }) => FundDetailsState(
    status: status ?? this.status,
    fundId: fundId ?? this.fundId,
    fund: fund ?? this.fund,
    availableWatchlists: availableWatchlists ?? this.availableWatchlists,
    selectedWatchlistId: clearSelectedWatchlist
        ? null
        : selectedWatchlistId ?? this.selectedWatchlistId,
    selectedHistoryPeriod: selectedHistoryPeriod ?? this.selectedHistoryPeriod,
    isAddingToWatchlist: isAddingToWatchlist ?? this.isAddingToWatchlist,
    isWatchlistPickerOpen: isWatchlistPickerOpen ?? this.isWatchlistPickerOpen,
    message: clearMessage ? null : message ?? this.message,
    messageVersion: messageVersion ?? this.messageVersion,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
