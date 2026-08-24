import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import 'watchlist_management_sheet.dart';

Future<void> showWatchlistSettingsSheet(
  BuildContext context,
  WatchlistBloc bloc,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const WatchlistSettingsSheet(),
    ),
  );
}

class WatchlistSettingsSheet extends StatelessWidget {
  const WatchlistSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: BlocSelector<
              WatchlistBloc,
              WatchlistState,
              ({List<Watchlist> watchlists, bool isSaving})
            >(
              selector: (state) =>
                  (watchlists: state.watchlists, isSaving: state.isSaving),
              builder: (context, data) {
                final pinned = data.watchlists
                    .where((item) => item.id == WatchlistBloc.defaultWatchlistId)
                    .toList(growable: false);
                final userWatchlists = data.watchlists
                    .where((item) => item.id != WatchlistBloc.defaultWatchlistId)
                    .toList(growable: false);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'WATCHLIST SETTINGS',
                      style: context.appTextStyles.tableHeader,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final watchlist in pinned)
                      _PinnedWatchlistTile(watchlist: watchlist),
                    if (userWatchlists.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(
                          'Create a watchlist to reorder it here.',
                          style: context.appTextStyles.bodySecondary,
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: userWatchlists.length,
                        onReorderItem: data.isSaving
                            ? (_, _) {}
                            : (oldIndex, newIndex) =>
                                  context.read<WatchlistBloc>().add(
                                    WatchlistsReorderRequested(
                                      oldIndex: oldIndex,
                                      newIndex: newIndex >= oldIndex
                                          ? newIndex + 1
                                          : newIndex,
                                    ),
                                  ),
                        proxyDecorator: (child, index, animation) =>
                            AnimatedBuilder(
                              animation: animation,
                              builder: (context, _) => Material(
                                elevation: animation.value * 2,
                                borderRadius: AppRadius.mdBorderRadius,
                                clipBehavior: Clip.antiAlias,
                                child: child,
                              ),
                            ),
                        itemBuilder: (context, index) {
                          final watchlist = userWatchlists[index];
                          return _UserWatchlistTile(
                            key: ValueKey(watchlist.id),
                            watchlist: watchlist,
                            index: index,
                            enabled: !data.isSaving,
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PinnedWatchlistTile extends StatelessWidget {
  const _PinnedWatchlistTile({required this.watchlist});

  final Watchlist watchlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.push_pin_outlined,
        size: AppSizes.iconSm,
        color: context.appColors.textSecondary,
      ),
      title: Text(watchlist.name, style: context.appTextStyles.bodyMedium),
      subtitle: Text('Pinned', style: context.appTextStyles.caption),
    );
  }
}

class _UserWatchlistTile extends StatelessWidget {
  const _UserWatchlistTile({
    required this.watchlist,
    required this.index,
    required this.enabled,
    super.key,
  });

  final Watchlist watchlist;
  final int index;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ReorderableDragStartListener(
        index: index,
        enabled: enabled,
        child: Icon(
          Icons.drag_handle,
          size: AppSizes.iconSm,
          color: context.appColors.textSecondary,
        ),
      ),
      title: Text(watchlist.name, style: context.appTextStyles.bodyMedium),
      trailing: Icon(
        Icons.chevron_right,
        size: AppSizes.iconSm,
        color: context.appColors.textTertiary,
      ),
      onTap: enabled
          ? () => showWatchlistManagementSheet(
              context,
              bloc: context.read<WatchlistBloc>(),
              watchlist: watchlist,
            )
          : null,
    );
  }
}
