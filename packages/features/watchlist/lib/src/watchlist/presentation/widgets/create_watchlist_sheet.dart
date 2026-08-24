import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watchlist_bloc.dart';
import 'watchlist_name_sheet.dart';

Future<void> showCreateWatchlistSheet(
  BuildContext context,
  WatchlistBloc bloc,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) =>
      BlocProvider.value(value: bloc, child: const WatchlistNameSheet.create()),
);
