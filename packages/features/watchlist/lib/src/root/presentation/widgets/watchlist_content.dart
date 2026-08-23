import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_event.dart';
import '../../../watchlist/presentation/bloc/watchlist_state.dart';
import '../../../watchlist/presentation/widgets/watchlist_header.dart';
import '../../../watchlist/presentation/widgets/watchlist_section.dart';
import '../../../watchlist/presentation/widgets/create_watchlist_sheet.dart';
import '../../../watchlist/presentation/widgets/watchlist_management_sheet.dart';
import 'watchlist_market_indices.dart';
import 'watchlist_skeleton.dart';

class WatchlistContent extends StatelessWidget {
  const WatchlistContent({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WatchlistHeader(onSearch: navigator?.openSearch),
                const SizedBox(height: AppSpacing.lg),
                const WatchlistMarketIndices(),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: BlocBuilder<WatchlistBloc, WatchlistState>(
                    builder: (context, state) => switch (state.status) {
                      WatchlistStatus.initial ||
                      WatchlistStatus.loading => const WatchlistSkeleton(),
                      WatchlistStatus.error => _WatchlistError(
                        onRetry: () => context.read<WatchlistBloc>().add(
                          const WatchlistRetryRequested(),
                        ),
                      ),
                      WatchlistStatus.empty => const WatchlistSection(
                        watchlists: [],
                        selectedWatchlistId: null,
                        funds: [],
                      ),
                      WatchlistStatus.loaded => WatchlistSection(
                        watchlists: state.watchlists,
                        selectedWatchlistId: state.selectedWatchlistId,
                        funds: state.visibleFunds,
                        onSelected: (watchlistId) => context
                            .read<WatchlistBloc>()
                            .add(WatchlistSelected(watchlistId: watchlistId)),
                        onLongPressed: (watchlist) =>
                            showWatchlistManagementSheet(
                              context,
                              bloc: context.read<WatchlistBloc>(),
                              watchlist: watchlist,
                            ),
                        onAddPressed:
                            state.watchlists.length <
                                    WatchlistBloc.maximumWatchlists &&
                                !state.isSaving
                            ? () => showCreateWatchlistSheet(
                                context,
                                context.read<WatchlistBloc>(),
                              )
                            : null,
                        onStockTap: (fund) => navigator?.openFund(
                          fundId: fund.id,
                          exchange: fund.tradeExchange,
                        ),
                        onReorder: (oldIndex, newIndex) {
                          final watchlistId = state.selectedWatchlistId;
                          if (watchlistId == null || state.isSaving) return;
                          context.read<WatchlistBloc>().add(
                            WatchlistFundsReorderRequested(
                              watchlistId: watchlistId,
                              oldIndex: oldIndex,
                              // The bloc retains Flutter's legacy insertion-index
                              // contract; the widget reports the adjusted index.
                              newIndex: newIndex > oldIndex
                                  ? newIndex + 1
                                  : newIndex,
                            ),
                          );
                        },
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WatchlistError extends StatelessWidget {
  const _WatchlistError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppErrorState(
    title: 'Unable to load watchlists.',
    description: 'Please try loading your watchlists again.',
    onRetry: onRetry,
  );
}
