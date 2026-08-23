import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

enum WatchlistNameAction { create, rename }

class WatchlistNameSheet extends StatefulWidget {
  const WatchlistNameSheet.create({super.key})
    : action = WatchlistNameAction.create,
      watchlist = null;

  const WatchlistNameSheet.rename({required this.watchlist, super.key})
    : action = WatchlistNameAction.rename;

  final WatchlistNameAction action;
  final Watchlist? watchlist;

  @override
  State<WatchlistNameSheet> createState() => _WatchlistNameSheetState();
}

class _WatchlistNameSheetState extends State<WatchlistNameSheet> {
  late final TextEditingController _controller;
  bool _submitted = false;
  String? _error;

  bool get _isCreate => widget.action == WatchlistNameAction.create;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.watchlist?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (!_isCreate && value == widget.watchlist!.name) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _submitted = true;
      _error = null;
    });
    final bloc = context.read<WatchlistBloc>();
    bloc.add(
      _isCreate
          ? WatchlistCreateRequested(name: value)
          : WatchlistRenameRequested(
              watchlistId: widget.watchlist!.id,
              newName: value,
            ),
    );
  }

  bool _didSucceed(WatchlistState state) {
    final value = _controller.text.trim();
    if (_isCreate) {
      return state.watchlists.any((item) => item.name == value);
    }
    return state.watchlists.any(
      (item) => item.id == widget.watchlist!.id && item.name == value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (!_submitted) return;
        if (_didSucceed(state) && !state.isSaving) {
          Navigator.pop(context);
        } else if (!state.isSaving && state.message != null) {
          setState(() {
            _submitted = false;
            _error = state.message;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isCreate ? 'CREATE WATCHLIST' : 'RENAME WATCHLIST',
                    style: context.appTextStyles.tableHeader,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    key: const Key('watchlist-name-field'),
                    controller: _controller,
                    autofocus: true,
                    enabled: !_submitted,
                    maxLength: WatchlistBloc.maximumNameLength,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: _isCreate ? 'Watchlist Name' : 'Current Name',
                      errorText: _error,
                    ),
                    onSubmitted: (_) {
                      if (!_submitted) _submit();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitted
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      BlocBuilder<WatchlistBloc, WatchlistState>(
                        buildWhen: (previous, current) =>
                            previous.isSaving != current.isSaving,
                        builder: (context, state) => AppButton(
                          label: _isCreate ? 'Create' : 'Save',
                          onPressed: _submitted || state.isSaving
                              ? null
                              : _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
