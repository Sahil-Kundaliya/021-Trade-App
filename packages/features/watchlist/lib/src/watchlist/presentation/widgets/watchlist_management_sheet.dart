import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import 'delete_watchlist_confirmation.dart';
import 'rename_watchlist_sheet.dart';

enum WatchlistManagementAction { rename, delete }

Future<void> showWatchlistManagementSheet(
  BuildContext context, {
  required WatchlistBloc bloc,
  required Watchlist watchlist,
}) async {
  final action = await showModalBottomSheet<WatchlistManagementAction>(
    context: context,
    useSafeArea: true,
    builder: (_) => WatchlistManagementSheet(watchlist: watchlist),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case WatchlistManagementAction.rename:
      await showRenameWatchlistSheet(context, bloc, watchlist);
      return;
    case WatchlistManagementAction.delete:
      await showDeleteWatchlistConfirmation(context, bloc, watchlist);
      return;
  }
}

class WatchlistManagementSheet extends StatelessWidget {
  const WatchlistManagementSheet({required this.watchlist, super.key});

  final Watchlist watchlist;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'WATCHLIST OPTIONS',
                style: context.appTextStyles.tableHeader,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(watchlist.name, style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename Watchlist'),
                onTap: () =>
                    Navigator.pop(context, WatchlistManagementAction.rename),
              ),
              if (watchlist.id != WatchlistBloc.defaultWatchlistId)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: context.appColors.negative,
                  ),
                  title: Text(
                    'Delete Watchlist',
                    style: TextStyle(color: context.appColors.negative),
                  ),
                  onTap: () =>
                      Navigator.pop(context, WatchlistManagementAction.delete),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
