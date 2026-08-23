import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/watchlist.dart';
import '../bloc/watchlist_bloc.dart';
import 'watchlist_name_sheet.dart';

Future<void> showRenameWatchlistSheet(
  BuildContext context,
  WatchlistBloc bloc,
  Watchlist watchlist,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => BlocProvider.value(
    value: bloc,
    child: WatchlistNameSheet.rename(watchlist: watchlist),
  ),
);
