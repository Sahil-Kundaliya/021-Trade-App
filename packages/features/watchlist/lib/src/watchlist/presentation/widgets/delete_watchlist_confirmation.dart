import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

Future<void> showDeleteWatchlistConfirmation(
  BuildContext context,
  WatchlistBloc bloc,
  Watchlist watchlist,
) => showDialog<void>(
  context: context,
  builder: (_) => BlocProvider.value(
    value: bloc,
    child: DeleteWatchlistConfirmation(watchlist: watchlist),
  ),
);

class DeleteWatchlistConfirmation extends StatefulWidget {
  const DeleteWatchlistConfirmation({required this.watchlist, super.key});

  final Watchlist watchlist;

  @override
  State<DeleteWatchlistConfirmation> createState() =>
      _DeleteWatchlistConfirmationState();
}

class _DeleteWatchlistConfirmationState
    extends State<DeleteWatchlistConfirmation> {
  bool _submitted = false;
  String? _error;

  void _delete() {
    setState(() {
      _submitted = true;
      _error = null;
    });
    context.read<WatchlistBloc>().add(
      WatchlistDeleteRequested(watchlistId: widget.watchlist.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (!_submitted) return;
        final deleted = !state.watchlists.any(
          (item) => item.id == widget.watchlist.id,
        );
        if (deleted && !state.isSaving) {
          Navigator.pop(context);
        } else if (!state.isSaving && state.message != null) {
          setState(() {
            _submitted = false;
            _error = state.message;
          });
        }
      },
      child: AlertDialog(
        title: const Text('DELETE WATCHLIST?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete "${widget.watchlist.name}"?'),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Funds in this Watchlist will only be removed from this '
                'Watchlist. The actual instruments and Holdings will not be '
                'deleted.',
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.negative,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitted ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<WatchlistBloc, WatchlistState>(
            buildWhen: (previous, current) =>
                previous.isSaving != current.isSaving,
            builder: (context, state) => TextButton(
              onPressed: _submitted || state.isSaving ? null : _delete,
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.negative,
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}
